#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

LIFECYCLE="${1:-}"
ACTION="${2:-}"
KEY="${3:-}"

if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${BLUE}${BOLD}Which environment?${NC}"
  echo -e "  ${GREEN}dev${NC}"
  echo -e "  ${YELLOW}stage${NC}"
  echo -e "  ${RED}prod${NC}"
  echo ""
  echo -n -e "Environment? [dev] "
  read -r LIFECYCLE
  LIFECYCLE="${LIFECYCLE:-dev}"
fi

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
echo ""

if [[ -z "$ACTION" ]]; then
  echo -e "${BLUE}${BOLD}What would you like to do?${NC}"
  echo -e "  ${GREEN}list${NC}   ${DIM}List all secret keys in app-secrets${NC}"
  echo -e "  ${GREEN}get${NC}    ${DIM}Get a specific secret value${NC}"
  echo -e "  ${GREEN}add${NC}    ${DIM}Add or update a secret interactively${NC}"
  echo ""
  echo -n -e "Action? [list] "
  read -r ACTION
  ACTION="${ACTION:-list}"
fi

case "$ACTION" in
  list)
    echo -e "${BLUE}${BOLD}Secrets in app-secrets [${NAMESPACE}]${NC}"
    kubectl get secret app-secrets -n "$NAMESPACE" -o json \
      | python3 -c "import sys,json; [print('  \033[0;32m' + k + '\033[0m') for k in sorted(json.load(sys.stdin)['data'].keys())]"
    ;;
  get)
    if [[ -z "$KEY" ]]; then
      echo -e "${BLUE}${BOLD}Available keys:${NC}"
      kubectl get secret app-secrets -n "$NAMESPACE" -o json \
        | python3 -c "import sys,json; [print('  \033[0;32m' + k + '\033[0m') for k in sorted(json.load(sys.stdin)['data'].keys())]"
      echo ""
      echo -n -e "Which key? "
      read -r KEY
      if [[ -z "$KEY" ]]; then
        echo -e "${RED}Key is required${NC}"
        exit 1
      fi
    fi
    echo -e "${BLUE}${KEY}${NC} [${NAMESPACE}]"
    kubectl get secret app-secrets -n "$NAMESPACE" -o jsonpath="{.data.${KEY}}" | base64 -d && echo
    ;;
  eso-status)
    echo -e "${BLUE}${BOLD}ExternalSecret status [${NAMESPACE}]${NC}"
    kubectl get externalsecret app-secrets -n "$NAMESPACE" -o yaml \
      | grep -A 20 "^status:"
    ;;
  secretstore-sync)
    echo -e "${BLUE}${BOLD}Forcing SecretStore reconcile [${NAMESPACE}]${NC}"
    kubectl annotate secretstore secret-store \
      force-sync="$(date +%s)" \
      -n "$NAMESPACE" --overwrite
    sleep 15
    echo -e "${BLUE}${BOLD}SecretStore status [${NAMESPACE}]${NC}"
    kubectl get secretstore secret-store -n "$NAMESPACE" \
      -o jsonpath='{.status.conditions[0].message}' && echo
    echo -e "${BLUE}${BOLD}ExternalSecret status [${NAMESPACE}]${NC}"
    kubectl get externalsecret app-secrets -n "$NAMESPACE" \
      -o jsonpath='{.status.conditions[0].reason}: {.status.conditions[0].message}' && echo
    ;;
  add)
    exec "$(dirname "$0")/add-secret.sh" "$LIFECYCLE"
    ;;
  *)
    echo -e "${YELLOW}Usage: secrets.sh [lifecycle] [list|get|add|eso-status] [key]${NC}"
    exit 1
    ;;
esac
