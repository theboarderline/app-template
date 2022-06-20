
all: install

update:
	kpt pkg update bin
	kpt pkg update deploy/web-app

dep:
	helm dep update ./deploy/web-app

install: dep
	helm upgrade -i ${NAMESPACE} -f ./deploy/values/values.yaml ./deploy/web-app -f ./deploy/values/${LIFECYCLE}.yaml -n ${NAMESPACE} --create-namespace --set web-app.lifecycle=${LIFECYCLE} --set web-app.gke_project_id=${GKE_PROJECT} --set web-app.db_project_id=${DB_PROJECT} --set web-app.app_code=${APP_CODE} --set web-app.domain=${DOMAIN}

dry: dep
	helm template ${NAMESPACE} ./deploy/web-app -f ./deploy/values/values.yaml -f ./deploy/values/${LIFECYCLE}.yaml --set web-app.lifecycle=${LIFECYCLE} --set web-app.gke_project_id=${GKE_PROJECT} --set web-app.db_project_id=${DB_PROJECT} --set web-app.app_code=${APP_CODE} --set web-app.domain=${DOMAIN}

