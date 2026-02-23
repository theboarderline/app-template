#!/usr/bin/env bash

# Bootstraps a lifecycle from scratch:
#   1. Connect to cluster
#   2. Create Artifact Registry repo
#   3. Create Cloud Build trigger
#   4. Push secrets to GCP Secret Manager
#   5. Submit first build

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

LIFECYCLE="${1:-}"

if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${RED}Usage: init.sh <dev|stage|prod>${NC}"
  exit 1
fi

DIR="$(dirname "$0")"
source "${DIR}/../app.sh"

NAMESPACE="${LIFECYCLE}-${APP_CODE}"

echo -e "${BLUE}${BOLD}Initializing ${NAMESPACE} [${APP_PROJECT}]${NC}"
echo ""

# 1. Cluster
echo -e "${BLUE}${BOLD}[1/5] Connecting to cluster...${NC}"
"${DIR}/cluster.sh" "$LIFECYCLE"
echo ""

# 2. Artifact Registry
echo -e "${BLUE}${BOLD}[2/5] Creating Artifact Registry repo...${NC}"
"${DIR}/registry.sh" create "$LIFECYCLE"
echo ""

# 3. Cloud Build trigger
echo -e "${BLUE}${BOLD}[3/5] Creating Cloud Build trigger...${NC}"
"${DIR}/triggers.sh" create "$LIFECYCLE"
echo ""

# 4. Secrets
echo -e "${BLUE}${BOLD}[4/5] Pushing secrets to GCP Secret Manager...${NC}"
"${DIR}/env-push.sh" "$LIFECYCLE"
echo ""

# 5. Submit build
echo -e "${BLUE}${BOLD}[5/5] Submitting first build...${NC}"
"${DIR}/triggers.sh" run "$LIFECYCLE"
echo ""

echo -e "${GREEN}${BOLD}✅ ${NAMESPACE} initialized — stream logs with:${NC}"
echo -e "  ${DIM}make build-logs-${LIFECYCLE:0:1}${NC}"
