#!/bin/bash

set -e

BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

LIFECYCLE=${1:-dev}
ACTION=${2:-status}

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
RELEASE_NAME="$NAMESPACE"
echo ""

case "$ACTION" in
  status)
    echo -e "${BLUE}${BOLD}Helm status [${RELEASE_NAME}]${NC}"
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    ;;
  values)
    echo -e "${BLUE}${BOLD}Helm values [${RELEASE_NAME}]${NC}"
    helm get values "$RELEASE_NAME" -n "$NAMESPACE"
    ;;
  history)
    echo -e "${BLUE}${BOLD}Helm history [${RELEASE_NAME}]${NC}"
    helm history "$RELEASE_NAME" -n "$NAMESPACE"
    ;;
  upgrade)
    DIR="$(dirname "$0")"
    HELM_VERSION="${HELM_VERSION:-$(grep '_HELM_VERSION:' "${DIR}/../cloudbuild.yaml" | sed "s/.*'\(.*\)'/\1/")}"
    echo -e "${BLUE}${BOLD}Helm upgrade [${RELEASE_NAME}] v${HELM_VERSION}${NC}"
    helm repo add tbl-charts https://theboarderline.github.io/helm-charts 2>/dev/null || true
    helm repo update 2>/dev/null || true
    helm upgrade --install --disable-openapi-validation \
      -f "${DIR}/../helm/values/values.yaml" \
      -f "${DIR}/../helm/values/${LIFECYCLE}.yaml" \
      --set app_code="${APP_CODE}" \
      --set lifecycle="${LIFECYCLE}" \
      "${RELEASE_NAME}" tbl-charts/web-app \
      --version "${HELM_VERSION}" \
      -n "${NAMESPACE}"
    ;;
  *)
    echo -e "${YELLOW}Usage: helm.sh <lifecycle> [status|values|history|upgrade]${NC}"
    exit 1
    ;;
esac
