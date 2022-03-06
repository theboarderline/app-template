
CHART ?= ./charts/web-app
LIFECYCLE ?= ops
API_TAG ?= latest
NGINX_TAG ?= latest

all: dep install
clean: delete


dep:
	helm dep update ${CHART}


install:
	helm upgrade -i ${LIFECYCLE}-${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml -n ${LIFECYCLE}-${NAMESPACE} --create-namespace --set web-app.gke_project_id=${GKE_PROJECT} --set web-app.db_project_id=${DB_PROJECT}


local:
	kubectl config use-context rancher-desktop || exit 1
	helm upgrade -i ${LIFECYCLE}-${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml -n ${LIFECYCLE}-${NAMESPACE} --create-namespace --set web-app.local=true --set web-app.secrets.enabled=false --set web-app.gke_project_id=${GKE_PROJECT} --set web-app.db_project_id=${DB_PROJECT}


dry:
	helm template ${LIFECYCLE}-${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml --set web-app.gke_project_id=${GKE_PROJECT} --set web-app.db_project_id=${DB_PROJECT}


dry-local:
	helm template ${LIFECYCLE}-${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml --set web-app.local=true --set web-app.secrets.enabled=false --set web-app.gke_project_id=${GKE_PROJECT} --set web-app.db_project_id=${DB_PROJECT}


delete:
	helm delete ${LIFECYCLE}-${NAMESPACE} -n ${LIFECYCLE}-${NAMESPACE}



