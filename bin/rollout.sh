#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

LIFECYCLE=${1:-dev}
ACTION=${2:-restart}
TARGET=${3:-api}
REPLICAS=${4:-}

DEPLOY_NAME="${TARGET}-dep"

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
echo ""

case "$ACTION" in
  restart)
    echo -e "${BLUE}Restarting ${BOLD}${DEPLOY_NAME}${NC} ${BLUE}[${NAMESPACE}]${NC}"
    kubectl rollout restart "deployment/${DEPLOY_NAME}" -n "$NAMESPACE"
    kubectl rollout status "deployment/${DEPLOY_NAME}" -n "$NAMESPACE"
    echo -e "${GREEN}${BOLD}${DEPLOY_NAME} restarted${NC}"
    ;;
  scale)
    if [[ -z "$REPLICAS" ]]; then
      echo -e "${RED}Usage: rollout.sh <lifecycle> scale <target> <replicas>${NC}"
      exit 1
    fi
    echo -e "${BLUE}Scaling ${BOLD}${DEPLOY_NAME}${NC} ${BLUE}to ${BOLD}${REPLICAS}${NC} ${BLUE}replicas [${NAMESPACE}]${NC}"
    kubectl scale "deployment/${DEPLOY_NAME}" -n "$NAMESPACE" --replicas="$REPLICAS"
    echo -e "${GREEN}${BOLD}${DEPLOY_NAME} scaled to ${REPLICAS}${NC}"
    ;;
  *)
    echo -e "${YELLOW}Usage: rollout.sh <lifecycle> [restart|scale] <target> [replicas]${NC}"
    exit 1
    ;;
esac
