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
  echo -e "${BLUE}${BOLD}Which environment to clean?${NC}"
  echo -e "  ${GREEN}dev${NC}"
  echo -e "  ${YELLOW}stage${NC}"
  echo -e "  ${RED}prod${NC}"
  echo ""
  echo -n -e "Environment? [dev] "
  read -r LIFECYCLE
  LIFECYCLE="${LIFECYCLE:-dev}"
fi

source "$(dirname "$0")/cluster.sh" "$LIFECYCLE"
echo ""

KNOWN_KEYS=(
  "secret-key"
  "django-key"
  "sendgrid-key"
  "openai-key"
  "twilio-account-sid"
  "twilio-auth-token"
)

echo -e "${BLUE}${BOLD}Checking for unused secrets in ${NAMESPACE}${NC}"
echo ""

CLUSTER_KEYS=$(kubectl get secret app-secrets -n "$NAMESPACE" -o json | python3 -c "
import sys, json
data = json.load(sys.stdin).get('data', {})
for k in sorted(data.keys()):
    print(k)
")

ORPHANS=()
for KEY in $CLUSTER_KEYS; do
  FOUND=false
  for KNOWN in "${KNOWN_KEYS[@]}"; do
    if [[ "$KEY" == "$KNOWN" ]]; then
      FOUND=true
      break
    fi
  done

  if [[ "$FOUND" == "false" ]]; then
    echo -e "  ${YELLOW}UNKNOWN${NC}  ${KEY}"
    ORPHANS+=("$KEY")
  else
    echo -e "  ${DIM}KNOWN${NC}    ${KEY}"
  fi
done

echo ""

if [[ ${#ORPHANS[@]} -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}No unused secrets found${NC}"
  exit 0
fi

echo -e "${BOLD}Found ${#ORPHANS[@]} unmanaged secret(s):${NC}"
echo ""

TO_REMOVE=()
for i in "${!ORPHANS[@]}"; do
  KEY="${ORPHANS[$i]}"
  echo -n -e "  Remove ${YELLOW}${KEY}${NC}? [y/N] "
  read -r CHOICE
  if [[ "$CHOICE" == "y" || "$CHOICE" == "Y" ]]; then
    TO_REMOVE+=("$KEY")
  fi
done

echo ""

if [[ ${#TO_REMOVE[@]} -eq 0 ]]; then
  echo -e "${DIM}Nothing to remove${NC}"
  exit 0
fi

echo -e "${BOLD}Will remove ${#TO_REMOVE[@]} secret(s):${NC}"
for KEY in "${TO_REMOVE[@]}"; do
  echo -e "  ${RED}- ${KEY}${NC}"
done
echo ""

if [[ "$LIFECYCLE" == "prod" ]]; then
  echo -e "${RED}${BOLD}You are cleaning secrets in PRODUCTION (${NAMESPACE})${NC}"
  echo -n -e "${RED}Type 'yes' to confirm: ${NC}"
  read -r CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 1
  fi
else
  echo -n -e "Confirm removal? [y/N] "
  read -r CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 1
  fi
fi

echo ""

PATCH_DATA=""
for KEY in "${TO_REMOVE[@]}"; do
  PATCH_DATA="${PATCH_DATA}\"${KEY}\":null,"
done
PATCH_DATA="${PATCH_DATA%,}"

kubectl patch secret app-secrets -n "$NAMESPACE" -p "{\"data\":{${PATCH_DATA}}}" > /dev/null

echo -e "${GREEN}${BOLD}Removed ${#TO_REMOVE[@]} secret(s) from ${NAMESPACE}${NC}"

echo ""
echo -e "${BLUE}Remaining secrets:${NC}"
kubectl get secret app-secrets -n "$NAMESPACE" -o json | python3 -c "
import sys, json
data = json.load(sys.stdin).get('data', {})
for k in sorted(data.keys()):
    print(f'  {k}')
"
