#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
DIM='\033[2m'

LIFECYCLE="${1:-}"

if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${BLUE}${BOLD}Available environment files:${NC}"
  FOUND=()
  for ENV in dev stage prod; do
    if [[ -f "src/api/.envs/.env.${ENV}" ]]; then
      echo -e "  ${GREEN}${ENV}${NC}  ${DIM}(src/api/.envs/.env.${ENV})${NC}"
      FOUND+=("$ENV")
    else
      echo -e "  ${DIM}${ENV}  (src/api/.envs/.env.${ENV} — not found)${NC}"
    fi
  done

  if [[ ${#FOUND[@]} -eq 0 ]]; then
    echo ""
    echo -e "${RED}No .env files found${NC}"
    echo -e "${DIM}Create src/api/.envs/.env.dev with your dev secrets to get started${NC}"
    exit 1
  fi

  echo ""
  echo -n -e "Which environment? [${FOUND[0]}] "
  read -r LIFECYCLE
  LIFECYCLE="${LIFECYCLE:-${FOUND[0]}}"
fi

ENV_FILE="src/api/.envs/.env.${LIFECYCLE}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo -e "${RED}${BOLD}File not found: ${ENV_FILE}${NC}"
  echo -e "${DIM}Create it with the secrets for the ${LIFECYCLE} environment${NC}"
  exit 1
fi

source "$(dirname "$0")/../app.sh"
# SECRET_MAP is defined in app.sh

echo -e "${BLUE}${BOLD}Checking secrets in ${ENV_FILE} against GCP Secret Manager (${APP_PROJECT})${NC}"
echo ""

declare -A FILE_VALUES
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  KEY="${line%%=*}"
  VAL="${line#*=}"
  VAL="${VAL%\"}"
  VAL="${VAL#\"}"
  VAL="${VAL%\'}"
  VAL="${VAL#\'}"
  FILE_VALUES["$KEY"]="$VAL"
done < "$ENV_FILE"

CHANGES=()
NEW_KEYS=()
UNCHANGED=()

for ENV_VAR in $(echo "${!SECRET_MAP[@]}" | tr ' ' '\n' | sort); do
  SECRET_NAME="${SECRET_MAP[$ENV_VAR]}"
  FILE_VAL="${FILE_VALUES[$ENV_VAR]:-}"

  if [[ -z "$FILE_VAL" ]]; then
    continue
  fi

  MASKED="${FILE_VAL:0:4}...${FILE_VAL: -4}"

  CURRENT_VAL=$(gcloud secrets versions access latest \
    --secret="$SECRET_NAME" \
    --project="$APP_PROJECT" 2>/dev/null || true)

  if [[ -z "$CURRENT_VAL" ]]; then
    echo -e "  ${GREEN}NEW${NC}        ${SECRET_NAME} ${DIM}(${ENV_VAR}=${MASKED})${NC}"
    NEW_KEYS+=("$SECRET_NAME:$FILE_VAL")
  elif [[ "$CURRENT_VAL" == "$FILE_VAL" ]]; then
    echo -e "  ${DIM}UNCHANGED${NC}  ${SECRET_NAME}"
    UNCHANGED+=("$SECRET_NAME")
  else
    echo -e "  ${YELLOW}CHANGED${NC}    ${SECRET_NAME} ${DIM}(${ENV_VAR}=${MASKED})${NC}"
    CHANGES+=("$SECRET_NAME:$FILE_VAL")
  fi
done

echo ""

TOTAL_UPDATES=$(( ${#CHANGES[@]} + ${#NEW_KEYS[@]} ))

if [[ $TOTAL_UPDATES -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}All secrets are up to date${NC}"
  exit 0
fi

echo -e "${BOLD}Summary:${NC} ${#NEW_KEYS[@]} new, ${#CHANGES[@]} changed, ${#UNCHANGED[@]} unchanged"
echo ""

if [[ "$LIFECYCLE" == "prod" ]]; then
  echo -e "${RED}${BOLD}You are pushing to PRODUCTION (${APP_PROJECT})${NC}"
  echo -n -e "${RED}Type 'yes' to confirm: ${NC}"
  read -r CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 1
  fi
elif [[ ! -t 0 ]]; then
  echo -e "${DIM}Non-interactive — auto-confirming${NC}"
else
  echo -n -e "Push ${TOTAL_UPDATES} secret(s) to Secret Manager? [y/N] "
  read -r CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 1
  fi
fi

echo ""

ALL_UPDATES=("${NEW_KEYS[@]}" "${CHANGES[@]}")
VERIFIED=0

for ENTRY in "${ALL_UPDATES[@]}"; do
  SECRET_NAME="${ENTRY%%:*}"
  VALUE="${ENTRY#*:}"

  if ! gcloud secrets describe "$SECRET_NAME" --project="$APP_PROJECT" > /dev/null 2>&1; then
    echo -e "${BLUE}Creating secret ${SECRET_NAME}...${NC}"
    gcloud secrets create "$SECRET_NAME" \
      --project="$APP_PROJECT" \
      --replication-policy="automatic" > /dev/null
  fi

  echo -n "$VALUE" | gcloud secrets versions add "$SECRET_NAME" \
    --data-file=- \
    --project="$APP_PROJECT" > /dev/null

  VERIFIED=$((VERIFIED + 1))
  echo -e "  ${GREEN}OK${NC}  ${SECRET_NAME}"
done

echo ""
echo -e "${GREEN}${BOLD}Pushed ${VERIFIED}/${TOTAL_UPDATES} secret(s) to Secret Manager (${APP_PROJECT})${NC}"
echo -e "${DIM}ESO will sync to app-secrets automatically${NC}"

# Mirror secret-key → django-key (chart uses django.enabled: true which expects django-key in GCP SM)
SECRET_KEY_VAL="${FILE_VALUES[SECRET_KEY]:-}"
if [[ -n "$SECRET_KEY_VAL" ]]; then
  DJANGO_CURRENT=$(gcloud secrets versions access latest --secret="django-key" --project="$APP_PROJECT" 2>/dev/null || true)
  if [[ "$DJANGO_CURRENT" != "$SECRET_KEY_VAL" ]]; then
    if ! gcloud secrets describe "django-key" --project="$APP_PROJECT" > /dev/null 2>&1; then
      gcloud secrets create "django-key" --project="$APP_PROJECT" --replication-policy="automatic" > /dev/null
    fi
    echo -n "$SECRET_KEY_VAL" | gcloud secrets versions add "django-key" --data-file=- --project="$APP_PROJECT" > /dev/null
    echo -e "  ${GREEN}OK${NC}  django-key ${DIM}(mirrored from SECRET_KEY)${NC}"
  else
    echo -e "  ${DIM}UNCHANGED${NC}  django-key"
  fi
fi
