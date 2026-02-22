#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ACTION="${1:-list}"
LIFECYCLE="${2:-}"

source "$(dirname "$0")/../app.sh"

LOCATION="us-central1"

repo_name() {
  local lc=$1
  echo "${lc}-${APP_CODE}-v3-images"
}

case "$ACTION" in
  list)
    echo -e "${BLUE}${BOLD}Artifact Registry repos [${APP_PROJECT}]${NC}"
    gcloud artifacts repositories list \
      --project="${APP_PROJECT}" \
      --location="${LOCATION}" \
      --format="table(name,format,createTime)" \
      2>/dev/null || echo -e "  ${YELLOW}No repos found or not authenticated${NC}"
    ;;

  create)
    if [[ -z "$LIFECYCLE" ]]; then
      echo -e "${RED}Usage: registry.sh create <dev|stage|prod>${NC}"
      exit 1
    fi
    REPO=$(repo_name "$LIFECYCLE")
    echo -e "${BLUE}${BOLD}Creating repo ${REPO} [${APP_PROJECT}]${NC}"
    if gcloud artifacts repositories describe "${REPO}" \
        --project="${APP_PROJECT}" \
        --location="${LOCATION}" &>/dev/null; then
      echo -e "  ${YELLOW}Already exists — skipping${NC}"
    else
      gcloud artifacts repositories create "${REPO}" \
        --repository-format=docker \
        --location="${LOCATION}" \
        --project="${APP_PROJECT}"
      echo -e "${GREEN}${BOLD}Repo '${REPO}' created${NC}"
    fi
    ;;

  delete)
    if [[ -z "$LIFECYCLE" ]]; then
      echo -e "${RED}Usage: registry.sh delete <dev|stage|prod>${NC}"
      exit 1
    fi
    REPO=$(repo_name "$LIFECYCLE")
    echo -e "${YELLOW}${BOLD}Deleting repo ${REPO} [${APP_PROJECT}]${NC}"
    gcloud artifacts repositories delete "${REPO}" \
      --project="${APP_PROJECT}" \
      --location="${LOCATION}" \
      --quiet
    echo -e "${GREEN}${BOLD}Repo '${REPO}' deleted${NC}"
    ;;

  *)
    echo -e "${YELLOW}Usage: registry.sh [list|create|delete] [lifecycle]${NC}"
    exit 1
    ;;
esac
