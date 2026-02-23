#!/usr/bin/env bash

CLUSTER_NAME=$1
LOCATION=$2
PROJECT=$3
NAMESPACE=$4
HELM_VERSION=$5
TAG=$6
REGIONAL=$7

if [[ ! $CLUSTER_NAME ]]; then
  echo "Must pass CLUSTER_NAME as 1st arg"
  exit 1
fi

if [[ ! $LOCATION ]]; then
  echo "Must pass LOCATION as 2nd arg"
  exit 1
fi

if [[ ! $PROJECT ]]; then
  echo "Must pass PROJECT as 3rd arg"
  exit 1
fi

if [[ ! $NAMESPACE ]]; then
  echo "Must pass NAMESPACE as 4th arg"
  exit 1
fi

if [[ ! $HELM_VERSION ]]; then
  echo "Must pass HELM_VERSION as 5th arg"
  exit 1
fi

if [[ ! $TAG ]]; then
  TAG='latest'
fi

if [[ $REGIONAL == "true" ]]; then
  gcloud container clusters get-credentials $CLUSTER_NAME --region=$LOCATION --project=$PROJECT || exit 1
else
  gcloud container clusters get-credentials $CLUSTER_NAME --zone=$LOCATION --project=$PROJECT || exit 1
fi

# Extract lifecycle and app_code from namespace (e.g., dev-coleman -> dev, coleman)
LIFECYCLE=${NAMESPACE%%-*}
APP_CODE=${NAMESPACE#*-}

helm repo add tbl-charts https://theboarderline.github.io/helm-charts
helm repo update
helm upgrade --install --reuse-values --disable-openapi-validation \
  -f helm/values/values.yaml \
  -f helm/values/$LIFECYCLE.yaml \
  $NAMESPACE tbl-charts/web-app \
  --version $HELM_VERSION \
  -n $NAMESPACE \
  --set app_code=$APP_CODE \
  --set lifecycle=$LIFECYCLE \
  --set nginx.tag=$TAG \
  --set api.tag=$TAG
