#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

ACTION="${1:-list}"
LIFECYCLE="${2:-}"

source "$(dirname "$0")/../app.sh"

gke_project() {
  local lc=$1
  if [[ "$lc" == "prod" ]]; then
    echo "${PROD_GKE_PROJECT}"
  else
    echo "${DEV_GKE_PROJECT}"
  fi
}

branch_for() {
  local lc=$1
  case "$lc" in
    prod)  echo "main" ;;
    stage) echo "stage" ;;
    *)     echo "dev" ;;
  esac
}

trigger_name() {
  local lc=$1
  echo "${APP_CODE}-${lc}"
}

case "$ACTION" in
  list)
    echo -e "${BLUE}${BOLD}Cloud Build triggers [${APP_PROJECT}]${NC}"
    gcloud builds triggers list \
      --project="${APP_PROJECT}" \
      --format="table(name,github.push.branch,createTime)" \
      2>/dev/null || echo -e "  ${YELLOW}No triggers found or not authenticated${NC}"
    ;;

  create)
    if [[ -z "$LIFECYCLE" ]]; then
      echo -e "${RED}Usage: triggers.sh create <dev|stage|prod>${NC}"
      exit 1
    fi
    NAME=$(trigger_name "$LIFECYCLE")
    BRANCH=$(branch_for "$LIFECYCLE")
    GKE_PROJECT=$(gke_project "$LIFECYCLE")

    echo -e "${BLUE}${BOLD}Creating trigger ${NAME} [${APP_PROJECT}]${NC}"
    echo -e "  Branch:       ${BRANCH}"
    echo -e "  Lifecycle:    ${LIFECYCLE}"
    echo -e "  GKE project:  ${GKE_PROJECT}"
    echo ""

    gcloud builds triggers create github \
      --project="${APP_PROJECT}" \
      --name="${NAME}" \
      --repo-name="${APP_CODE}" \
      --repo-owner="theboarderline" \
      --branch-pattern="^${BRANCH}$" \
      --build-config="cloudbuild.yaml" \
      --substitutions="_LIFECYCLE=${LIFECYCLE},_APP_CODE=${APP_CODE},_GKE_PROJECT=${GKE_PROJECT}"

    echo -e "${GREEN}${BOLD}Trigger '${NAME}' created${NC}"
    ;;

  run)
    if [[ -z "$LIFECYCLE" ]]; then
      echo -e "${RED}Usage: triggers.sh run <dev|stage|prod>${NC}"
      exit 1
    fi
    NAME=$(trigger_name "$LIFECYCLE")
    BRANCH=$(branch_for "$LIFECYCLE")
    GKE_PROJECT=$(gke_project "$LIFECYCLE")

    echo -e "${BLUE}${BOLD}Running trigger ${NAME} [${APP_PROJECT}]${NC}"

    gcloud builds triggers run "${NAME}" \
      --project="${APP_PROJECT}" \
      --branch="${BRANCH}" \
      --substitutions="_LIFECYCLE=${LIFECYCLE},_APP_CODE=${APP_CODE},_GKE_PROJECT=${GKE_PROJECT}"

    echo ""
    echo -e "${GREEN}${BOLD}Build submitted — stream logs with:${NC}"
    echo -e "  ${DIM}make build-logs-${LIFECYCLE:0:1}${NC}"
    ;;

  describe)
    if [[ -z "$LIFECYCLE" ]]; then
      echo -e "${RED}Usage: triggers.sh describe <dev|stage|prod>${NC}"
      exit 1
    fi
    NAME=$(trigger_name "$LIFECYCLE")
    echo -e "${BLUE}${BOLD}Trigger: ${NAME} [${APP_PROJECT}]${NC}"
    gcloud builds triggers describe "${NAME}" --project="${APP_PROJECT}"
    ;;

  ephemeral)
    NAME="${APP_CODE}-ephemeral"
    echo -e "${BLUE}${BOLD}Creating ephemeral trigger ${NAME} [${APP_PROJECT}]${NC}"
    echo -e "  Branch pattern: (?i)${JIRA_KEY}-[0-9]+"
    echo -e "  Build config:   cloudbuild-ephemeral.yaml"
    echo ""
    gcloud builds triggers create github \
      --project="${APP_PROJECT}" \
      --name="${NAME}" \
      --repo-name="${APP_CODE}" \
      --repo-owner="theboarderline" \
      --branch-pattern="(?i)${JIRA_KEY}-[0-9]+" \
      --build-config="cloudbuild-ephemeral.yaml" \
      --substitutions="_APP_CODE=${APP_CODE},_GKE_PROJECT=${DEV_GKE_PROJECT},_JIRA_KEY=${JIRA_KEY},_LIFECYCLE="
    echo -e "${GREEN}${BOLD}Trigger '${NAME}' created${NC}"
    ;;

  update-ep)
    NAME="${APP_CODE}-ephemeral"
    echo -e "${BLUE}${BOLD}Updating ephemeral trigger ${NAME} [${APP_PROJECT}]${NC}"
    gcloud builds triggers delete "${NAME}" --project="${APP_PROJECT}" --quiet 2>/dev/null || true
    gcloud builds triggers create github \
      --project="${APP_PROJECT}" \
      --name="${NAME}" \
      --repo-name="${APP_CODE}" \
      --repo-owner="theboarderline" \
      --branch-pattern="(?i)${JIRA_KEY}-[0-9]+" \
      --build-config="cloudbuild-ephemeral.yaml" \
      --substitutions="_APP_CODE=${APP_CODE},_GKE_PROJECT=${DEV_GKE_PROJECT},_JIRA_KEY=${JIRA_KEY},_LIFECYCLE="
    echo -e "${GREEN}${BOLD}Trigger '${NAME}' updated${NC}"
    ;;

  run-ep)
    BRANCH="${LIFECYCLE}"
    if [[ -z "$BRANCH" ]]; then
      echo -e "${RED}Usage: triggers.sh run-ep <${JIRA_KEY^^}-N>${NC}"
      exit 1
    fi
    NAME="${APP_CODE}-ephemeral"
    LIFECYCLE_LC=$(lifecycle_from_branch "$BRANCH")
    if [[ -z "$LIFECYCLE_LC" ]]; then
      echo -e "${RED}Could not extract Jira key from branch: ${BRANCH}${NC}"
      exit 1
    fi
    echo -e "${BLUE}${BOLD}Running ephemeral trigger for branch ${BRANCH} [${APP_PROJECT}]${NC}"
    gcloud builds triggers run "${NAME}" \
      --project="${APP_PROJECT}" \
      --branch="${BRANCH}" \
      --substitutions="_APP_CODE=${APP_CODE},_GKE_PROJECT=${DEV_GKE_PROJECT},_LIFECYCLE=${LIFECYCLE_LC}"
    echo ""
    echo -e "${GREEN}${BOLD}Build submitted — stream logs with:${NC}"
    echo -e "  ${DIM}make build-logs LIFECYCLE=${LIFECYCLE_LC}${NC}"
    ;;

  *)
    echo -e "${YELLOW}Usage: triggers.sh [list|create|run|describe|ephemeral|run-ep] [lifecycle/branch]${NC}"
    exit 1
    ;;
esac
