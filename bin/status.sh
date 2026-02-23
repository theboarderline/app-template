#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
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
  ext-dns)
    echo -e "${BLUE}${BOLD}External DNS pods${NC}"
    kubectl get pods -A -l "app.kubernetes.io/name=external-dns" 2>/dev/null \
      || kubectl get pods -A 2>/dev/null | grep -i external-dns \
      || echo -e "  ${YELLOW}No external-dns pods found${NC}"
    echo ""
    echo -e "${BLUE}${BOLD}External DNS logs (last 30)${NC}"
    NS=$(kubectl get pods -A -l "app.kubernetes.io/name=external-dns" \
      -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo "")
    if [[ -n "$NS" ]]; then
      kubectl logs -n "$NS" -l "app.kubernetes.io/name=external-dns" --tail=30 2>/dev/null \
        | grep -iE "${APP_CODE}|error|sync|record|desired" || echo "  (no relevant log lines)"
    else
      echo -e "  ${YELLOW}External DNS not found — DNS records must be managed manually${NC}"
    fi
    ;;
  dns-check)
    DIR="$(dirname "$0")"
    DOMAIN=$(grep '^domain:' "${DIR}/../helm/values/values.yaml" | awk '{print $2}')
    SUB="${LIFECYCLE}.${DOMAIN}"
    INGRESS_IP=$(kubectl get ingress app-ingress -n "$NAMESPACE" \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "unknown")
    echo -e "${BLUE}${BOLD}DNS check [${NAMESPACE}]${NC}"
    echo -e "  Subdomain:  ${SUB}"
    echo -e "  Ingress IP: ${INGRESS_IP}"
    echo -e "  DNS lookup:"
    DNS_IP=$(dig +short "$SUB" 2>/dev/null | head -1 || true)
    if [[ -z "$DNS_IP" ]]; then
      echo -e "    ${YELLOW}No DNS record found for ${SUB}${NC}"
    elif [[ "$DNS_IP" == "$INGRESS_IP" ]]; then
      echo -e "    ${GREEN:-\033[0;32m}OK${NC}  ${DNS_IP} ✓"
    else
      echo -e "    ${YELLOW}MISMATCH — DNS: ${DNS_IP}, Ingress: ${INGRESS_IP}${NC}"
    fi
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
