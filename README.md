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
- [GKE Auth](#gke)
- [Getting Started](#getting_started)
- [Built Using](#built_using)
- [CI/CD](#cicd)
- [Authors](#authors)

## 🎈 Contents <a name="contents"></a>

# The following directories should only updated with Kpt
`bin` - contains shell scripts to simplify local development (Update with Kpt)
`deploy/web-app` - contains web app Helm Chart for deploying to GKE (UPDATE with Kpt)

# These directories/files are specific to the app and should be updated manually
`deploy/values` - contains values files for each lifecycle to deploy to with Helm Chart
`src` - contains starter code with React frontend and Django Rest Framework API
## TODO: fill in values when repo gets created
`app.sh` - shell script to set app specific environment variables


## 🎈 GKE Auth <a name="gke"></a>

```
# Initialize environment variables - only needed if interacting with GKE cluster
source ./bin/env.sh

```

## 🏁 Getting Started <a name = "getting_started"></a>

Run frontend server
```
cd react
yarn install
yarn start
```

Run backend server

```
# Initialize python virtual env
cd api
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
- [Docker](https://www.docker.com/) - Build Container Images
- [Kubernetes](https://kubernetes.io/) - Container Orchestration
- [Helm](https://helm..sh/) - Kubernetes Deployment Manager
- [Google Cloud Platform](https://www.cloud.google.com/) - Public Cloud Platform
- [Cloud SQL](https://https://cloud.google.com/sql) - Google Managed Database
## TODO: update link below with app code
- [Terraform](https://terraform.io/) - Cloud IAC -> repo found [here](https://github.com/theboarderline/<APP_CODE>-iac.git/)


## 🚀 CI/CD <a name = "cicd"></a>
## TODO: update link below with app code
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




