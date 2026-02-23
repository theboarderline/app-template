#!/usr/bin/env bash

# Destroys an ephemeral environment and cleans up all associated resources.
#
# Usage: teardown.sh <branch-or-lifecycle>
# Example: teardown.sh CGS-42
#          teardown.sh cgs-42

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

INPUT="${1:-}"

if [[ -z "$INPUT" ]]; then
  echo -e "${RED}Usage: teardown.sh <branch-or-lifecycle>${NC}"
  echo -e "${RED}Example: teardown.sh CGS-42${NC}"
  exit 1
fi

DIR="$(dirname "$0")"
source "${DIR}/../app.sh"

LIFECYCLE=$(lifecycle_from_branch "$INPUT")
if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${RED}Could not extract Jira key from: ${INPUT}${NC}"
  exit 1
fi
NAMESPACE="${LIFECYCLE}-${APP_CODE}"

echo -e "${YELLOW}${BOLD}Tearing down ${NAMESPACE} [${APP_PROJECT}]${NC}"
echo ""

# 1. Cluster context
"${DIR}/cluster.sh" dev

# 2. Helm uninstall
echo -e "${BLUE}${BOLD}[1/4] Helm uninstall...${NC}"
helm uninstall "${NAMESPACE}" -n "${NAMESPACE}" --ignore-not-found 2>/dev/null || true
echo ""

# 3. Delete namespace
echo -e "${BLUE}${BOLD}[2/4] Deleting namespace...${NC}"
kubectl delete namespace "${NAMESPACE}" --ignore-not-found
echo ""

# 4. Remove Workload Identity binding
echo -e "${BLUE}${BOLD}[3/4] Removing WI binding...${NC}"
WI_MEMBER="serviceAccount:${DEV_GKE_PROJECT}.svc.id.goog[${NAMESPACE}/${APP_CODE}-sa]"
gcloud iam service-accounts remove-iam-policy-binding \
  "${APP_CODE}-workload@${APP_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="${WI_MEMBER}" \
  --project="${APP_PROJECT}" \
  > /dev/null 2>&1 \
  && echo -e "  Removed WI binding" \
  || echo -e "  ${YELLOW}WI binding not found — skipping${NC}"
echo ""

# 5. Delete lifecycle-scoped GCP SM secrets
echo -e "${BLUE}${BOLD}[4/4] Cleaning GCP SM secrets...${NC}"
SECRETS=(secret-key django-key openai-key sendgrid-key twilio-account-sid twilio-auth-token)
for SECRET in "${SECRETS[@]}"; do
  SCOPED="${LIFECYCLE}-${SECRET}"
  if gcloud secrets describe "${SCOPED}" --project="${APP_PROJECT}" &>/dev/null; then
    gcloud secrets delete "${SCOPED}" --project="${APP_PROJECT}" --quiet
    echo -e "  Deleted: ${SCOPED}"
  else
    echo -e "  ${YELLOW}Not found: ${SCOPED} — skipping${NC}"
  fi
done
echo ""

echo -e "${GREEN}${BOLD}✅ ${NAMESPACE} torn down${NC}"
