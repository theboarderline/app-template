<p align="center">
  <a href="" rel="noopener">
</p>

<h3 align="center">Templated Web App</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)


</div>

---


## 📝 Table of Contents

- [Contents](#contents)
- [Local Development Prerequisites](#prereqs)
- [GKE Auth](#gke)
- [Getting Started](#getting_started)
- [Built Using](#built_using)
- [CI/CD](#cicd)
- [Authors](#authors)

## 🎈 Contents <a name="contents"></a>

### The following directories can be updated with Kpt using `kpt pkg update <PATH>`

`bin`            - contains shell scripts to simplify local development
`deploy/web-app` - contains web app Helm Chart for deploying to GKE


### These directories/files are specific to the app and should be updated manually

`deploy/values` - contains values files for each lifecycle to deploy to with Helm Chart  
`src` - contains starter code with React frontend and Django Rest Framework API  
#### TODO: fill in values within the file after repo gets created
`app.sh` - shell script to set app specific environment variables


## Local Development Prerequisites

App Dev
- [Yarn](https://yarnpkg.com/getting-started/install)
- [Python3](https://www.python.org/downloads/)
- [Golang](https://go.dev/)

DevOps
- [Gcloud](https://cloud.google.com/sdk/docs/install)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

## 🎈 GKE Auth <a name="gke"></a>

```
# Initialize environment variables - only needed if interacting with GKE cluster
source ./bin/env.sh
```

## 🏁 Getting Started <a name = "getting_started"></a>

Run frontend server (or use [WebStorm by JetBrains](https://www.jetbrains.com/webstorm/) for simplified long-term development)
```
cd src/react
yarn install
yarn start
```

In a new shell, run backend server (or use [PyCharm by JetBrains](https://www.jetbrains.com/pycharm/) for simplified long-term development)

```
# Initialize python virtual env
cd src/api
python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt

# Initialize database
./bin/init_db.sh

# Run server
python3 manage.py runserver
```


## ⛏️ Built Using <a name = "built_using"></a>

- [Django Rest Framework](https://www.django-rest-framework.org/) - Python Rest API framework
- [ReactJS](https://reactjs.org/) - Typescript Frontend library
- [Google Cloud Platform](https://www.cloud.google.com/) - Public Cloud Provider
- [GKE](https://cloud.google.com/kubernetes-engine) - Google Managed Kubernetes
- [Helm](https://helm..sh/) - Kubernetes Package Manager
- [Cloud SQL](https://https://cloud.google.com/sql) - Google Managed Database
- [Config Connector](https://cloud.google.com/config-connector/docs/overview) - Infrastructure Provisioning


## 🚀 CI/CD <a name = "cicd"></a>
### TODO: update link below with app code
The following branches have Cloud Build Triggers [found here](https://console.cloud.google.com/cloud-build/builds?project=<APP_CODE>-app-project&supportedpurview=project) that will build and deploy images on a push
- `ops`
- `dev`
- `test`
- `stage`
- `main`

## ✍️ Authors <a name = "authors"></a>

- [@walkerobrien](https://github.com/walkerobrien) 
  - Project Manager
  - Cloud Architect
  - Lead Developer


- [@silascoleman](https://github.com/silascoleman) 
  - Project Manager
  - Sales Lead

