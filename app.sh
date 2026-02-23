#!/usr/bin/env bash

export APP_CODE='your-app'
export APP_PROJECT="${APP_CODE}-app-project"
export DOMAIN='your-domain.com'

export DEV_GKE_PROJECT="d-platform-gke-project-hsw"
export PROD_GKE_PROJECT="p-platform-gke-project-qjo"

export DNS_PROJECT="tbl-dns-project"
export DNS_CLUSTER_NAME="central-cluster"
export DNS_CLUSTER_ZONE="us-central1-a"

export JIRA_KEY="abc"

# Extract the Jira key (e.g. abc-1) from any branch name.
lifecycle_from_branch() {
  echo "$1" | grep -oiE "${JIRA_KEY}-[0-9]+" | tr '[:upper:]' '[:lower:]' | head -1
}

# Map of env var names → GCP Secret Manager secret names.
# Used by env-push.sh and env-pull.sh.
# Add app-specific secrets here.
declare -A SECRET_MAP
SECRET_MAP=(
  ["SECRET_KEY"]="secret-key"
)
