
export LIFECYCLE=$1

if [[ $LIFECYCLE != "ops" && $LIFECYCLE != "dev" && $LIFECYCLE != "test" && $LIFECYCLE != "stage" && $LIFECYCLE != "prod" ]]; then
    echo "Must set LIFECYCLE to ops/dev/test/stage/prod in bash env"
    exit 1
fi

source "$(dirname "$0")/../app.sh"

export NAMESPACE="${LIFECYCLE}-${APP_CODE}"
export LIFECYCLE_LETTER="${LIFECYCLE:0:1}"

if [[ "$LIFECYCLE" == "prod" ]]; then
  export GKE_PROJECT="${PROD_GKE_PROJECT}"
else
  export GKE_PROJECT="${DEV_GKE_PROJECT}"
fi

export CLUSTER="central-cluster"
export REGION="us-central1"
export ZONE="${REGION}-a"

export IS_LOCAL=True

./bin/gke-auth.sh
