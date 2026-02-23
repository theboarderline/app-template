#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

LIFECYCLE="${1:-}"
TARGET="${2:-}"

if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${BLUE}${BOLD}Which environment?${NC}"
  echo -e "  ${GREEN}dev${NC}"
  echo -e "  ${YELLOW}stage${NC}"
  echo -e "  ${BLUE}prod${NC}"
  echo ""
  echo -n -e "Environment? [dev] "
  read -r LIFECYCLE
  LIFECYCLE="${LIFECYCLE:-dev}"
fi

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
echo ""

if [[ -z "$TARGET" ]]; then
  echo -e "${BLUE}${BOLD}Which pod?${NC}"
  echo -e "  ${GREEN}api${NC}    ${DIM}API server (api-dep)${NC}"
  echo -e "  ${GREEN}nginx${NC}  ${DIM}Nginx proxy (nginx-dep)${NC}"
  echo ""
  echo -n -e "Pod? [api] "
  read -r TARGET
  TARGET="${TARGET:-api}"
fi

case "$TARGET" in
  api)
    echo -e "${BLUE}Exec into ${BOLD}api-dep${NC} ${BLUE}[${NAMESPACE}]${NC}"
    POD=$(kubectl get pods -n "$NAMESPACE" -l app=api-dep -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -it -n "$NAMESPACE" "$POD" -- sh
    ;;
  nginx)
    echo -e "${BLUE}Exec into ${BOLD}nginx-dep${NC} ${BLUE}[${NAMESPACE}]${NC}"
    POD=$(kubectl get pods -n "$NAMESPACE" -l app=nginx-dep -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -it -n "$NAMESPACE" "$POD" -- sh
    ;;
  *)
    echo -e "${YELLOW}Usage: kexec.sh <lifecycle> [api|nginx]${NC}"
    exit 1
    ;;
esac
