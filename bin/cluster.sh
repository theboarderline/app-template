#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

LIFECYCLE=${1:-dev}

source "$(dirname "$0")/../app.sh"

CLUSTER_NAME="central-cluster"
CLUSTER_ZONE="us-central1-a"

if [[ "$LIFECYCLE" == "prod" ]]; then
  GKE_PROJECT="${PROD_GKE_PROJECT}"
else
  GKE_PROJECT="${DEV_GKE_PROJECT}"
fi

NAMESPACE="${LIFECYCLE}-${APP_CODE}"

echo -e "${BLUE}Switching to ${BOLD}${LIFECYCLE}${NC}${BLUE} (${GKE_PROJECT})${NC}"

gcloud container clusters get-credentials "$CLUSTER_NAME" \
  --zone="$CLUSTER_ZONE" \
  --project="$GKE_PROJECT" 2>&1

kubectl config set-context --current --namespace="$NAMESPACE" > /dev/null

echo -e "${GREEN}${BOLD}Context: ${NAMESPACE}${NC}"
