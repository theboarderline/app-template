<p align="center">
  <a href="" rel="noopener">
</p>

<h3 align="center">Cloud Walk Sample App</h3>

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

Run backend tests

```
make test
```

Run backend server

```
make install
make run
```

## 🎈 Script Usage <a name="usage"></a>

```
# Ensure env variables are set
./bin/check_env.sh

# Authenticate with GKE cluster
./bin/auth.sh 

```

## ⛏️ Built Using <a name = "built_using"></a>

- [Gin](https://https://github.com/gin-gonic/gin) - Rest API Framework
- [ReactJS](https://reactjs.org/) - Typescript Frontend library
- [Cloud SQL](https://https://cloud.google.com/sql) - Google Managed Database
- [Docker](https://www.docker.com/) - Build Container Images
- [Kubernetes](https://kubernetes.io/) - Container Orchestration
- [Helm](https://helm.sh/) - Kubernetes Deployment
- [Terraform](https://terraform.io/) - Cloud Infrastructure Provisioning
- [Google Cloud Platform](https://www.cloud.google.com/) - Public Cloud

## 🚀 CI/CD Lifecycles <a name = "cicd"></a>
- `ops`
- `dev`
- `test`
- `stage`
- `main`

## ✍️ Authors <a name = "authors"></a>

- [@walkerobrien](https://github.com/walkerobrien) 
  - Project Manager
  - Architect
  - Lead Developer


