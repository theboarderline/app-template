#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

source "$(dirname "$0")/../app.sh"
GCP_BUILD_PROJECT="${GCP_BUILD_PROJECT:-${APP_PROJECT}}"
LIST_LIMIT=5

show_help() {
    cat << EOF
Usage: $(basename "$0") [LIFECYCLE] [--list]

View Cloud Build logs for the given lifecycle environment.

Arguments:
    LIFECYCLE    Environment (dev, stage, prod). Default: dev
    --list       List recent builds instead of streaming the latest log

Examples:
    $(basename "$0")              # Stream last dev build logs
    $(basename "$0") dev          # Stream last dev build logs
    $(basename "$0") prod         # Stream last prod build logs
    $(basename "$0") dev --list   # List last ${LIST_LIMIT} dev builds
    $(basename "$0") --list       # List last ${LIST_LIMIT} dev builds

Environment:
    GCP_BUILD_PROJECT    GCP project where Cloud Build runs (default: ${GCP_BUILD_PROJECT})
EOF
}

get_last_build_id() {
    local lifecycle=$1
    gcloud builds list \
        --project="${GCP_BUILD_PROJECT}" \
        --filter="substitutions._LIFECYCLE=${lifecycle}" \
        --format="value(id)" \
        --limit=1 \
        --sort-by="~createTime" \
        2>/dev/null
}

list_builds() {
    local lifecycle=$1

    echo -e "${CYAN}Recent Cloud Builds for lifecycle=${lifecycle} (project: ${GCP_BUILD_PROJECT})${NC}"
    echo ""

    gcloud builds list \
        --project="${GCP_BUILD_PROJECT}" \
        --filter="substitutions._LIFECYCLE=${lifecycle}" \
        --format="table(id,status,createTime,duration,substitutions._LIFECYCLE)" \
        --limit="${LIST_LIMIT}" \
        --sort-by="~createTime" \
        2>/dev/null || {
            echo -e "${RED}Failed to list builds. Are you authenticated? Try: gcloud auth login${NC}"
            exit 1
        }

    echo ""
    echo -e "To stream a specific build: ${YELLOW}gcloud builds log --stream <BUILD_ID> --project=${GCP_BUILD_PROJECT}${NC}"
}

stream_latest_log() {
    local lifecycle=$1

    echo -e "${CYAN}Fetching last Cloud Build for lifecycle=${lifecycle} (project: ${GCP_BUILD_PROJECT})...${NC}"

    local build_id
    build_id=$(get_last_build_id "$lifecycle")

    if [ -z "$build_id" ]; then
        echo -e "${RED}No builds found for lifecycle=${lifecycle}${NC}"
        echo "Make sure you're authenticated: gcloud auth login"
        exit 1
    fi

    local build_status
    build_status=$(gcloud builds describe "$build_id" \
        --project="${GCP_BUILD_PROJECT}" \
        --format="value(status)" 2>/dev/null)

    echo -e "Build ID: ${YELLOW}${build_id}${NC}  Status: ${YELLOW}${build_status}${NC}"
    echo ""

    if [ "$build_status" == "WORKING" ]; then
        echo -e "${GREEN}Build is in progress — streaming live logs...${NC}"
        echo ""
        gcloud builds log --stream "$build_id" --project="${GCP_BUILD_PROJECT}"
    else
        echo -e "Showing logs for completed build (status: ${build_status})..."
        echo ""
        gcloud builds log "$build_id" --project="${GCP_BUILD_PROJECT}"
    fi
}

main() {
    local lifecycle="dev"
    local list_mode=false

    for arg in "$@"; do
        case "$arg" in
            -h|--help) show_help; exit 0 ;;
            --list)    list_mode=true ;;
            -*) echo -e "${RED}Unknown argument: ${arg}${NC}"; show_help; exit 1 ;;
            *) lifecycle="$arg" ;;
        esac
    done

    if $list_mode; then
        list_builds "$lifecycle"
    else
        stream_latest_log "$lifecycle"
    fi
}

main "$@"
