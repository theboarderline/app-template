#!/bin/bash

# Bootstraps an ephemeral environment from a branch name.
# Idempotent — safe to run multiple times.
#
# Usage: ephemeral-init.sh <branch>
# Example: ephemeral-init.sh CGS-42
#
# Env vars:
#   HELM_VERSION  — override helm chart version (default: read from cloudbuild.yaml)

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

BRANCH="${1:-}"

if [[ -z "$BRANCH" ]]; then
  echo -e "${RED}Usage: ephemeral-init.sh <branch>${NC}"
  echo -e "${RED}Example: ephemeral-init.sh CGS-42${NC}"
  exit 1
fi

DIR="$(dirname "$0")"
source "${DIR}/../app.sh"

LIFECYCLE=$(lifecycle_from_branch "$BRANCH")
if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${RED}Could not extract Jira key from branch: ${BRANCH}${NC}"
  exit 1
fi
NAMESPACE="${LIFECYCLE}-${APP_CODE}"
HELM_VERSION="${HELM_VERSION:-$(grep '_HELM_VERSION:' "${DIR}/../cloudbuild.yaml" | sed "s/.*'\(.*\)'/\1/")}"

echo -e "${BLUE}${BOLD}Initializing ephemeral: ${NAMESPACE} [${APP_PROJECT}]${NC}"
echo ""

# 1. Registry
echo -e "${BLUE}${BOLD}[1/4] Registry...${NC}"
"${DIR}/registry.sh" create "${LIFECYCLE}"
echo ""

# 2. Seed lifecycle-scoped secrets in GCP SM from dev
echo -e "${BLUE}${BOLD}[2/4] Seeding secrets from dev...${NC}"
"${DIR}/seed-secrets.sh" "${LIFECYCLE}"
echo ""

# 3. Cluster context + namespace
echo -e "${BLUE}${BOLD}[3/4] Cluster + namespace...${NC}"
"${DIR}/cluster.sh" dev
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# Bind Workload Identity for this namespace's SA so ESO can access GCP SM
WI_MEMBER="serviceAccount:${DEV_GKE_PROJECT}.svc.id.goog[${NAMESPACE}/${APP_CODE}-sa]"
gcloud iam service-accounts add-iam-policy-binding \
  "${APP_CODE}-workload@${APP_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="${WI_MEMBER}" \
  --project="${APP_PROJECT}" \
  > /dev/null 2>&1 && echo -e "  ${GREEN}OK${NC}  WI binding: ${WI_MEMBER}" \
  || echo -e "  ${DIM}WI binding already exists${NC}"
echo ""

# 4. Helm install
echo -e "${BLUE}${BOLD}[4/4] Helm install...${NC}"
helm repo add tbl-charts https://theboarderline.github.io/helm-charts 2>/dev/null || true
helm repo update 2>/dev/null || true

helm upgrade --install --disable-openapi-validation \
  -f "${DIR}/../helm/values/values.yaml" \
  -f "${DIR}/../helm/values/ephemeral.yaml" \
  --set app_code="${APP_CODE}" \
  --set lifecycle="${LIFECYCLE}" \
  --set external_secrets.secret_prefix="${LIFECYCLE}-" \
  "${NAMESPACE}" tbl-charts/web-app \
  --version "${HELM_VERSION}" \
  -n "${NAMESPACE}"

echo ""
echo -e "${GREEN}${BOLD}✅ ${NAMESPACE} initialized${NC}"
echo -e "  ${DIM}Submit a build: make trigger-run-ep BRANCH=${BRANCH}${NC}"
