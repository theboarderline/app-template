#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

LIFECYCLE=${1:-dev}
SECRETS_FILE="src/api/.envs/.env.dev"

if [[ "$LIFECYCLE" != "dev" ]]; then
  echo -e "${RED}${BOLD}DENIED: env-pull can only be run against dev${NC}"
  echo -e "${DIM}This protects prod/stage secrets from being pulled to local machines${NC}"
  exit 1
fi

source "$(dirname "$0")/../app.sh"
# SECRET_MAP is defined in app.sh; invert it for pull (secret-name → ENV_VAR)
declare -A PULL_MAP
for ENV_VAR in "${!SECRET_MAP[@]}"; do
  PULL_MAP["${SECRET_MAP[$ENV_VAR]}"]="$ENV_VAR"
done

echo -e "${BLUE}${BOLD}Pulling secrets from GCP Secret Manager (${APP_PROJECT}) into ${SECRETS_FILE}${NC}"
echo ""

LINES=()

for SECRET_NAME in $(echo "${!PULL_MAP[@]}" | tr ' ' '\n' | sort); do
  ENV_VAR="${PULL_MAP[$SECRET_NAME]}"

  VALUE=$(gcloud secrets versions access latest \
    --secret="$SECRET_NAME" \
    --project="$APP_PROJECT" 2>/dev/null || true)

  if [[ -z "$VALUE" && "$SECRET_NAME" == "secret-key" ]]; then
    VALUE=$(gcloud secrets versions access latest \
      --secret="django-key" \
      --project="$APP_PROJECT" 2>/dev/null || true)
    [[ -n "$VALUE" ]] && echo -e "  ${YELLOW}FALLBACK${NC}  ${SECRET_NAME} — using django-key"
  fi

  if [[ -z "$VALUE" ]]; then
    echo -e "  ${YELLOW}SKIP${NC}  ${SECRET_NAME} — not found in Secret Manager"
    continue
  fi

  LINES+=("${ENV_VAR}=${VALUE}")
  echo -e "  ${GREEN}OK${NC}    ${ENV_VAR} ${DIM}(from ${SECRET_NAME})${NC}"
done

if [[ ${#LINES[@]} -eq 0 ]]; then
  echo ""
  echo -e "${YELLOW}No secrets found in Secret Manager${NC}"
  exit 1
fi

mkdir -p "$(dirname "$SECRETS_FILE")"
printf '%s\n' "${LINES[@]}" > "$SECRETS_FILE"

echo ""
echo -e "${GREEN}${BOLD}Wrote ${#LINES[@]} secrets to ${SECRETS_FILE}${NC}"
