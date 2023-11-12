
## Template App API

### Prerequisites
- [Golang 1.20](https://go.dev/doc/install)
- [Ginkgo](https://github.com/onsi/ginkgo)
- [Gcloud CLI](https://cloud.google.com/sdk/docs/install)

### Example `.env` file
```
SECRET_KEY=fake-key
```

### Installation

```bash
make install
```

### Run All Tests
```bash
make test
```

Run server

```bash
make run
```

### Test Docker
```bash
make container
```

### Running

Authenticate with GCP credentials
```bash
gcloud auth application-default login
```

## Live Environments

- [CloudBuild Triggers](https://console.cloud.google.com/cloud-build/builds?project=<APP_CODE>-app-project&supportedpurview=project)

