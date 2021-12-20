<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://storage.googleapis.com/cgs-static/cgs.png" alt="CGS Logo"></a>
</p>

<h3 align="center">Coleman Group Solutions Web App</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)


</div>

---

<p align="center"> Coleman Group Solutions web application built to provide my man Silas with a lead generation/management tool to get him rich
</p>

## 📝 Table of Contents

- [Getting Started](#getting_started)
- [Script Usage](#usage)
- [Built Using](#built_using)
- [CI/CD](#cicd)
- [Authors](#authors)

## 🏁 Getting Started <a name = "getting_started"></a>

Run frontend server
```
cd nginx/gui
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
# Authenticate with GKE cluster
./bin/auth.sh 

# Create storage bucket
./bin/buckets.sh 

# Ensure env variables are set
./bin/check_env.sh

# Create public IPs in GCP
./bin/buckets.sh 

# Helm script
./bin/helm.sh install|upgrade|delete dev|stage|prod

# Reset django database
./bin/reset_db.sh

# Init/get/push/delete secrets to GCP
./bin/secrets.sh init|get|push|delete

# Create/delete CI/CD triggers
./bin/triggers.sh create|delete|reset
```

## ⛏️ Built Using <a name = "built_using"></a>

- [Django Rest Framework](https://www.django-rest-framework.org/) - Python Rest API framework
- [ReactJS](https://reactjs.org/) - Typescript Frontend library
- [Cloud SQL](https://https://cloud.google.com/sql) - Google Managed Database
- [Docker](https://www.docker.com/) - Build Container Images
- [Kubernetes](https://kubernetes.io/) - Cloud Environment
- [Helm](https://helm..sh/) - Kubernetes Deployment
- [Terraform](https://terraform.io/) - Cloud IAC -> repo found [here](https://github.com/theboarderline/gke-infra.git/)
- [Google Cloud Platform](https://www.cloud.google.com/) - Public Cloud

## 🚀 CI/CD <a name = "cicd"></a>
The following branches are connected to [Google Cloud Build](https://console.cloud.google.com/cloud-build/builds?project=lg-v1-app-project) CI/CD pipelines 
- `dev`
- `stage`
- `master`

## ✍️ Authors <a name = "authors"></a>

- [@walkerobrien](https://github.com/walkerobrien) 
  - Project Manager
  - Lead Developer
  - Cloud Architect
- [@silascoleman](https://github.com/silascoleman) 
  - Project Manager



