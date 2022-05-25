#!/bin/zsh


source ./bin/check_env.sh


gcloud config set project $GKE_PROJECT

echo
gcloud container clusters get-credentials --zone=$ZONE $CLUSTER
kubectl config set-context --current --namespace $LIFECYCLE-$APP_CODE
echo
