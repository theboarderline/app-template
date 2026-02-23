#!/usr/bin/env bash

# Seeds GCP Secret Manager with lifecycle-scoped secrets copied from a source lifecycle.
# The chart's ExternalSecret references fixed key names (django-key, openai-key, etc.).
# This creates lifecycle-prefixed copies so each ephemeral env has its own GCP SM entries.
#
# Usage: seed-secrets.sh <lifecycle> [source-lifecycle]
# Example: seed-secrets.sh cgs-42           # copies from dev
#          seed-secrets.sh cgs-42 stage     # copies from stage-scoped secrets

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

LIFECYCLE="${1:-}"
SOURCE="${2:-dev}"

if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${RED}Usage: seed-secrets.sh <lifecycle> [source-lifecycle]${NC}"
  exit 1
fi

source "$(dirname "$0")/../app.sh"

SECRETS=(secret-key django-key openai-key sendgrid-key twilio-account-sid twilio-auth-token)

echo -e "${BLUE}${BOLD}Seeding GCP SM secrets: ${SOURCE} → ${LIFECYCLE} [${APP_PROJECT}]${NC}"

for SECRET in "${SECRETS[@]}"; do
  SCOPED="${LIFECYCLE}-${SECRET}"
  SOURCE_KEY="${SECRET}"
  if [[ "$SOURCE" != "dev" ]]; then
    SOURCE_KEY="${SOURCE}-${SECRET}"
  fi

  if gcloud secrets describe "${SCOPED}" --project="${APP_PROJECT}" &>/dev/null; then
    echo -e "  ${YELLOW}${SCOPED} already exists — skipping${NC}"
    continue
  fi

  VALUE=$(gcloud secrets versions access latest \
    --secret="${SOURCE_KEY}" --project="${APP_PROJECT}" 2>/dev/null || true)

  if [[ -z "$VALUE" ]]; then
    echo -e "  ${YELLOW}Source '${SOURCE_KEY}' not found in ${APP_PROJECT} — skipping${NC}"
    continue
  fi

  printf '%s' "${VALUE}" | gcloud secrets create "${SCOPED}" \
    --project="${APP_PROJECT}" --data-file=-

  echo -e "  ${GREEN}Created ${SCOPED}${NC}"
done

echo -e "${GREEN}${BOLD}Done seeding secrets for ${LIFECYCLE}${NC}"
