#!/bin/bash

set -e

BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

LIFECYCLE=${1:-dev}
VIEW=${2:-all}

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
echo ""

case "$VIEW" in
  pods)
    echo -e "${BLUE}${BOLD}Pods [${NAMESPACE}]${NC}"
    kubectl get pods -n "$NAMESPACE"
    ;;
  logs)
    echo -e "${BLUE}${BOLD}Tailing API logs [${NAMESPACE}]${NC}"
    kubectl logs -n "$NAMESPACE" -l app=api-dep --tail=100 -f
    ;;
  check-images)
    echo -e "${BLUE}${BOLD}Images [${NAMESPACE}]${NC}"
    kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .spec.containers[*]}  {.name}: {.image}{"\n"}{end}{end}'
    echo ""
    echo -e "${BLUE}${BOLD}Image pull errors [${NAMESPACE}]${NC}"
    kubectl get events -n "$NAMESPACE" --field-selector reason=Failed --sort-by='.lastTimestamp' 2>/dev/null | tail -10
    ;;
  dns-check)
    echo -e "${BLUE}${BOLD}DNS check [${NAMESPACE}]${NC}"
    kubectl get ingress -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.spec.rules[*].host}{"\n"}{end}' | while read -r HOST; do
      if [[ -n "$HOST" ]]; then
        echo -n "  $HOST → "
        dig +short "$HOST" | head -1 || echo "(no result)"
      fi
    done
    ;;
  all|*)
    echo -e "${BLUE}${BOLD}Pods [${NAMESPACE}]${NC}"
    kubectl get pods -n "$NAMESPACE"
    echo ""
    echo -e "${BLUE}${BOLD}Services [${NAMESPACE}]${NC}"
    kubectl get svc -n "$NAMESPACE"
    echo ""
    echo -e "${BLUE}${BOLD}Ingress [${NAMESPACE}]${NC}"
    kubectl get ingress -n "$NAMESPACE" 2>/dev/null || echo -e "  ${YELLOW}No ingress resources${NC}"
    ;;
esac
