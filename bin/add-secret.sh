#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

LIFECYCLE="${1:-}"

if [[ -z "$LIFECYCLE" ]]; then
  echo -e "${BLUE}${BOLD}Which environment?${NC}"
  echo -e "  ${GREEN}dev${NC}"
  echo -e "  ${YELLOW}stage${NC}"
  echo -e "  ${RED}prod${NC}"
  echo ""
  echo -n -e "Environment? [dev] "
  read -r LIFECYCLE
  LIFECYCLE="${LIFECYCLE:-dev}"
fi

ENV_FILE="src/api/.envs/.env.local"

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
echo ""

echo -e "${BOLD}${BLUE}==========================================${NC}"
echo -e "${BOLD}${BLUE}  Add Secret to app-secrets${NC}"
echo -e "${BOLD}${BLUE}==========================================${NC}"
echo -e "  Namespace: ${BOLD}${NAMESPACE}${NC}"
echo ""

kubectl get namespace "$NAMESPACE" > /dev/null 2>&1 || {
  echo -e "${RED}Error: Namespace '${NAMESPACE}' does not exist${NC}"
  exit 1
}

kubectl get secret app-secrets -n "$NAMESPACE" > /dev/null 2>&1 || {
  echo -e "${RED}Error: Secret 'app-secrets' does not exist in namespace '${NAMESPACE}'${NC}"
  exit 1
}

read -p "Enter the secret key name (e.g., new-api-key): " SECRET_KEY
if [[ -z "$SECRET_KEY" ]]; then
  echo -e "${RED}Error: Secret key name is required${NC}"
  exit 1
fi

EXISTING_VALUE=$(kubectl get secret app-secrets -n "$NAMESPACE" -o jsonpath="{.data.$SECRET_KEY}" 2>/dev/null || echo "")
if [[ -n "$EXISTING_VALUE" ]]; then
  echo -e "${YELLOW}Warning: Key '${SECRET_KEY}' already exists in app-secrets${NC}"
  read -p "Do you want to overwrite it? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
  fi
fi

echo ""
echo -e "${BOLD}Where should the value come from?${NC}"
echo -e "  ${GREEN}1${NC}) Enter manually"
echo -e "  ${GREEN}2${NC}) Read from ${ENV_FILE}"
read -p "Choice (1/2): " SOURCE_CHOICE

case "$SOURCE_CHOICE" in
  2)
    read -p "Enter the .env variable name (e.g., SENDGRID_KEY): " ENV_VAR
    if [[ -z "$ENV_VAR" ]]; then
      echo -e "${RED}Error: Variable name is required${NC}"
      exit 1
    fi
    if [[ ! -f "$ENV_FILE" ]]; then
      echo -e "${RED}Error: ${ENV_FILE} not found${NC}"
      exit 1
    fi
    SECRET_VALUE=$(grep "^${ENV_VAR}=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2- | sed "s/^['\"]//;s/['\"]$//")
    if [[ -z "$SECRET_VALUE" ]]; then
      echo -e "${RED}Error: ${ENV_VAR} not found in ${ENV_FILE}${NC}"
      exit 1
    fi
    echo -e "  ${DIM}Read value from ${ENV_VAR} (${#SECRET_VALUE} chars)${NC}"
    ;;
  *)
    read -s -p "Enter the secret value: " SECRET_VALUE
    echo
    if [[ -z "$SECRET_VALUE" ]]; then
      echo -e "${RED}Error: Secret value is required${NC}"
      exit 1
    fi
    read -s -p "Confirm the secret value: " SECRET_VALUE_CONFIRM
    echo
    if [[ "$SECRET_VALUE" != "$SECRET_VALUE_CONFIRM" ]]; then
      echo -e "${RED}Error: Secret values do not match${NC}"
      exit 1
    fi
    ;;
esac

echo ""
echo -e "${BOLD}About to apply:${NC}"
echo -e "  ${BOLD}Key:${NC}        ${SECRET_KEY}"
echo -e "  ${BOLD}Namespace:${NC}  ${NAMESPACE}"
echo -e "  ${BOLD}Value:${NC}      ${DIM}${SECRET_VALUE:0:8}...${NC} (${#SECRET_VALUE} chars)"
echo ""
read -p "Confirm? (y/N): " FINAL_CONFIRM
if [[ ! "$FINAL_CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Cancelled"
  exit 0
fi

ENCODED_VALUE=$(echo -n "$SECRET_VALUE" | base64)

echo ""
echo -e "${BLUE}Patching app-secrets in ${NAMESPACE}...${NC}"

kubectl patch secret app-secrets -n "$NAMESPACE" \
  --type='json' \
  -p="[{\"op\": \"add\", \"path\": \"/data/${SECRET_KEY}\", \"value\": \"${ENCODED_VALUE}\"}]"

echo ""

VERIFY_VALUE=$(kubectl get secret app-secrets -n "$NAMESPACE" -o jsonpath="{.data.$SECRET_KEY}" | base64 -d)
if [[ "$VERIFY_VALUE" == "$SECRET_VALUE" ]]; then
  echo -e "${GREEN}${BOLD}Secret '${SECRET_KEY}' added and verified in ${NAMESPACE}${NC}"
else
  echo -e "${RED}Verification failed: Secret value does not match${NC}"
  exit 1
fi
