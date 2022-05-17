<p align="center">
  <a href="" rel="noopener">
</p>

<h3 align="center">Sample Web App</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)


</div>

---


## 📝 Table of Contents

- [Getting Started](#getting_started)
- [Script Usage](#usage)
- [Built Using](#built_using)
- [CI/CD](#cicd)
- [Authors](#authors)

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

## 🎈 Script Usage <a name="usage"></a>

```
# Initialize environment variables
source ./envs/<LIFECYCLE>.sh

# Ensure env variables are set
./bin/check_env.sh


# Authenticate with GKE cluster
./bin/auth.sh 

```

## ⛏️ Built Using <a name = "built_using"></a>

- [Django Rest Framework](https://www.django-rest-framework.org/) - Python Rest API framework
- [ReactJS](https://reactjs.org/) - Typescript Frontend library
- [Docker](https://www.docker.com/) - Build Container Images
- [Kubernetes](https://kubernetes.io/) - Container Orchestration
- [Helm](https://helm..sh/) - Kubernetes Deployment Manager
- [Google Cloud Platform](https://www.cloud.google.com/) - Public Cloud Platform
- [Cloud SQL](https://https://cloud.google.com/sql) - Google Managed Database
## TODO: update link below with app code and delete comment
- [Terraform](https://terraform.io/) - Cloud IAC -> repo found [here](https://github.com/theboarderline/<APP_CODE>-iac.git/)


## 🚀 CI/CD <a name = "cicd"></a>
## TODO: update link below with app code and delete comment
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




