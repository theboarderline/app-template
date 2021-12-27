
CHART ?= ./charts/web-app
LIFECYCLE ?= ops
API_TAG ?= latest
NGINX_TAG ?= latest


all: dep install
clean: delete


dep:
	helm dep update ${CHART}


install:
	helm upgrade -i ${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml -n ${NAMESPACE} --create-namespace --set web-app.api.tag=${API_TAG} --set web-app.nginx.tag=${NGINX_TAG} 


local:
	kubectl config use-context rancher-desktop || exit 1
	helm upgrade -i ${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml -n ${NAMESPACE} --create-namespace --set web-app.local=true --set web-app.secrets.enabled=false --set web-app.api.tag=${API_TAG} --set web-app.nginx.tag=${NGINX_TAG}


dry:
	helm template ${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml --set web-app.api.tag=${API_TAG} --set web-app.nginx.tag=${NGINX_TAG}


dry-local:
	helm template ${NAMESPACE} ${CHART} -f ${CHART}/values/${LIFECYCLE}.yaml --set web-app.local=true --set web-app.secrets.enabled=false --set web-app.api.tag=${API_TAG} --set web-app.nginx.tag=${NGINX_TAG}


delete:
	helm delete ${NAMESPACE} -n ${NAMESPACE}

