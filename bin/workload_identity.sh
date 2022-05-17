#!/bin/zsh

source ./bin/check_env.sh


LIFECYCLES=(
  "ops"
  "dev"
  "test"
  "stage"
  "prod"
)

for CYCLE in ${LIFECYCLES[@]}; do
  gcloud iam service-accounts add-iam-policy-binding \
    --project $APP_PROJECT \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$GKE_PROJECT.svc.id.goog[$CYCLE-$NAMESPACE/$NAMESPACE-sa]" \
    $NAMESPACE-workload@$APP_PROJECT.iam.gserviceaccount.com
done
