#!/bin/bash

# Deploys External DNS to the central cluster using Workload Identity.
#
# Usage: ext-dns.sh [deploy|status|logs]
# Default action: deploy
#
# Requires: gcloud authed, kubectl context set, helm installed

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ACTION="${1:-deploy}"

DIR="$(dirname "$0")"
source "${DIR}/../app.sh"

_DNS_PROJECT="${DNS_PROJECT:-tbl-dns-project}"
_CLUSTER_NAME="${DNS_CLUSTER_NAME:-central-cluster}"
_CLUSTER_ZONE="${DNS_CLUSTER_ZONE:-us-central1-a}"
EXT_DNS_SA="external-dns@${APP_PROJECT}.iam.gserviceaccount.com"
EXT_DNS_NS="external-dns"
CHART_VERSION="1.11.0"

case "$ACTION" in
  deploy)
    echo -e "${BLUE}${BOLD}Deploying External DNS [${DEV_GKE_PROJECT}]${NC}"
    echo -e "  SA:          ${EXT_DNS_SA}"
    echo -e "  DNS project: ${_DNS_PROJECT}"
    echo -e "  Cluster:     ${_CLUSTER_NAME}"
    echo ""

    # 1. Cluster context (dev only — External DNS is cluster-wide)
    echo -e "${BLUE}${BOLD}[1/4] Cluster context...${NC}"
    "${DIR}/cluster.sh" dev
    echo ""

    # 2. GCP SA — create if it doesn't exist
    echo -e "${BLUE}${BOLD}[2/4] GCP service account...${NC}"
    if gcloud iam service-accounts describe "${EXT_DNS_SA}" \
        --project="${APP_PROJECT}" &>/dev/null; then
      echo -e "  ${DIM}SA already exists: ${EXT_DNS_SA}${NC}"
    else
      gcloud iam service-accounts create external-dns \
        --display-name="External DNS" \
        --project="${APP_PROJECT}"
      echo -e "  ${GREEN}Created SA: ${EXT_DNS_SA}${NC}"
    fi

    # Grant dns.admin on the DNS project
    gcloud projects add-iam-policy-binding "${_DNS_PROJECT}" \
      --member="serviceAccount:${EXT_DNS_SA}" \
      --role="roles/dns.admin" \
      --condition=None \
      > /dev/null 2>&1 \
      && echo -e "  ${GREEN}OK${NC}  dns.admin on ${_DNS_PROJECT}" \
      || echo -e "  ${YELLOW}Could not bind dns.admin — check permissions${NC}"
    echo ""

    # 3. Workload Identity binding
    echo -e "${BLUE}${BOLD}[3/4] Workload Identity binding...${NC}"
    WI_MEMBER="serviceAccount:${DEV_GKE_PROJECT}.svc.id.goog[${EXT_DNS_NS}/external-dns]"
    gcloud iam service-accounts add-iam-policy-binding "${EXT_DNS_SA}" \
      --role="roles/iam.workloadIdentityUser" \
      --member="${WI_MEMBER}" \
      --project="${APP_PROJECT}" \
      > /dev/null 2>&1 \
      && echo -e "  ${GREEN}OK${NC}  WI binding: ${WI_MEMBER}" \
      || echo -e "  ${DIM}WI binding already exists${NC}"
    echo ""

    # 4. Helm install
    echo -e "${BLUE}${BOLD}[4/4] Helm install/upgrade...${NC}"
    helm repo add external-dns https://kubernetes-sigs.github.io/external-dns 2>/dev/null || true
    helm repo update external-dns 2>/dev/null || true

    helm upgrade --install external-dns external-dns/external-dns \
      --version "${CHART_VERSION}" \
      --namespace "${EXT_DNS_NS}" \
      --create-namespace \
      --set provider=google \
      --set policy=sync \
      --set "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account=${EXT_DNS_SA}" \
      --set "extraArgs[0]=--google-project=${_DNS_PROJECT}" \
      --set "extraArgs[1]=--txt-owner-id=${_CLUSTER_NAME}" \
      --set resources.requests.cpu=".01" \
      --set resources.requests.memory="32Mi" \
      --set resources.limits.cpu=".05" \
      --set resources.limits.memory="64Mi" \
      --set securityContext.allowPrivilegeEscalation=false \
      --wait --timeout=120s

    echo ""
    echo -e "${GREEN}${BOLD}✅ External DNS deployed${NC}"
    echo -e "  ${DIM}Check status: make ext-dns${NC}"
    echo -e "  ${DIM}Check DNS:    make dns-check-d${NC}"
    ;;

  status)
    gcloud container clusters get-credentials "${_CLUSTER_NAME}" \
      --zone="${_CLUSTER_ZONE}" \
      --project="${DEV_GKE_PROJECT}" 2>/dev/null
    echo -e "${BLUE}${BOLD}External DNS pods [${EXT_DNS_NS}]${NC}"
    kubectl get pods -n "${EXT_DNS_NS}" 2>/dev/null \
      || echo -e "  ${YELLOW}Namespace not found — run: make ext-dns-deploy${NC}"
    echo ""
    echo -e "${BLUE}${BOLD}External DNS SA bindings${NC}"
    gcloud iam service-accounts get-iam-policy "${EXT_DNS_SA}" \
      --project="${APP_PROJECT}" \
      --format="table(bindings.role,bindings.members)" \
      2>/dev/null || echo -e "  ${YELLOW}SA not found${NC}"
    ;;

  logs)
    gcloud container clusters get-credentials "${_CLUSTER_NAME}" \
      --zone="${_CLUSTER_ZONE}" \
      --project="${DEV_GKE_PROJECT}" 2>/dev/null
    echo -e "${BLUE}${BOLD}External DNS logs (last 50)${NC}"
    kubectl logs -n "${EXT_DNS_NS}" -l "app.kubernetes.io/name=external-dns" \
      --tail=50 2>/dev/null \
      || echo -e "  ${YELLOW}No logs found — is External DNS running?${NC}"
    ;;

  *)
    echo -e "${YELLOW}Usage: ext-dns.sh [deploy|status|logs]${NC}"
    exit 1
    ;;
esac
