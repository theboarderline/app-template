#!/usr/bin/env bash

source ./bin/check_env.sh

gcloud config set project "$GKE_PROJECT"

echo
gcloud container clusters get-credentials "$CLUSTER" \
  --zone="$ZONE" \
  --project="$GKE_PROJECT"
kubectl config set-context --current --namespace "$NAMESPACE"
echo
