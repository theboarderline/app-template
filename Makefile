LIFECYCLE ?= dev
COMMIT_SHA := $(shell git rev-parse HEAD)
HELM_VERSION := $(shell bash -c "grep '_HELM_VERSION:' cloudbuild.yaml | sed \"s/.*'\\(.*\\)'/\\1/\"")
CLUSTER_NAME := central-cluster
CLUSTER_ZONE := us-central1-a

APP_CODE         := $(shell bash -c '. ./app.sh && echo $$APP_CODE')
APP_PROJECT      := $(shell bash -c '. ./app.sh && echo $$APP_PROJECT')
DEV_GKE_PROJECT  := $(shell bash -c '. ./app.sh && echo $$DEV_GKE_PROJECT')
PROD_GKE_PROJECT := $(shell bash -c '. ./app.sh && echo $$PROD_GKE_PROJECT')

ifeq ($(LIFECYCLE),prod)
  GKE_PROJECT := $(PROD_GKE_PROJECT)
else
  GKE_PROJECT := $(DEV_GKE_PROJECT)
endif

NAMESPACE := $(LIFECYCLE)-$(APP_CODE)


# 🩺 Health check — runs all read-only checks to verify the system
.PHONY: check
check:
	@echo "🩺 Running system check for $(NAMESPACE)..."
	@./bin/cluster.sh $(LIFECYCLE)
	@echo ""
	@./bin/status.sh $(LIFECYCLE) all
	@echo ""
	@./bin/helm.sh $(LIFECYCLE) status
	@echo ""
	@./bin/secrets.sh $(LIFECYCLE) list
	@echo ""
	@echo "✅ All checks passed for $(NAMESPACE)"

.PHONY: check-d check-s check-p
check-d: ; @$(MAKE) check LIFECYCLE=dev
check-s: ; @$(MAKE) check LIFECYCLE=stage
check-p: ; @$(MAKE) check LIFECYCLE=prod


# ⚓ Cluster
.PHONY: cluster
cluster:
	@./bin/cluster.sh $(LIFECYCLE)

.PHONY: cluster-d cluster-s cluster-p
cluster-d: ; @./bin/cluster.sh dev
cluster-s: ; @./bin/cluster.sh stage
cluster-p: ; @./bin/cluster.sh prod


# 🚀 Init lifecycle
.PHONY: init
init:
	@echo "🚀 Initializing $(LIFECYCLE)..."
	@./bin/init.sh $(LIFECYCLE)

.PHONY: init-d init-s init-p
init-d: ; @$(MAKE) init LIFECYCLE=dev
init-s: ; @$(MAKE) init LIFECYCLE=stage
init-p: ; @$(MAKE) init LIFECYCLE=prod

# Ephemeral — BRANCH=CGS-42
.PHONY: init-ep
init-ep:
	@echo "🚀 Initializing ephemeral $(BRANCH)..."
	@./bin/ephemeral-init.sh $(BRANCH)

.PHONY: teardown-ep
teardown-ep:
	@echo "💥 Tearing down ephemeral $(BRANCH)..."
	@./bin/teardown.sh $(BRANCH)

.PHONY: teardown
teardown:
	@echo "💥 Tearing down $(LIFECYCLE)..."
	@./bin/teardown.sh $(LIFECYCLE)

.PHONY: trigger-create-ep
trigger-create-ep:
	@./bin/triggers.sh ephemeral

.PHONY: trigger-update-ep
trigger-update-ep:
	@./bin/triggers.sh update-ep

.PHONY: trigger-run-ep
trigger-run-ep:
	@./bin/triggers.sh run-ep $(BRANCH)


# 📦 Artifact Registry
.PHONY: registry-list
registry-list:
	@./bin/registry.sh list

.PHONY: registry-create
registry-create:
	@./bin/registry.sh create $(LIFECYCLE)

.PHONY: registry-create-d registry-create-s registry-create-p
registry-create-d: ; @$(MAKE) registry-create LIFECYCLE=dev
registry-create-s: ; @$(MAKE) registry-create LIFECYCLE=stage
registry-create-p: ; @$(MAKE) registry-create LIFECYCLE=prod


# ☁️ Cloud Build
GCP_BUILD_PROJECT ?= $(APP_PROJECT)

.PHONY: build-logs
build-logs:
	@echo "☁️ Streaming last Cloud Build logs for $(LIFECYCLE)..."
	@GCP_BUILD_PROJECT=$(GCP_BUILD_PROJECT) ./bin/build-logs.sh $(LIFECYCLE)

.PHONY: build-list
build-list:
	@echo "☁️ Listing recent Cloud Builds for $(LIFECYCLE)..."
	@GCP_BUILD_PROJECT=$(GCP_BUILD_PROJECT) ./bin/build-logs.sh $(LIFECYCLE) --list

.PHONY: build-logs-d build-logs-s build-logs-p
build-logs-d: ; @$(MAKE) build-logs LIFECYCLE=dev
build-logs-s: ; @$(MAKE) build-logs LIFECYCLE=stage
build-logs-p: ; @$(MAKE) build-logs LIFECYCLE=prod


# 🚀 Triggers
.PHONY: trigger-list
trigger-list:
	@./bin/triggers.sh list

.PHONY: trigger-create-d trigger-create-s trigger-create-p
trigger-create-d:
	@./bin/triggers.sh create dev
trigger-create-s:
	@./bin/triggers.sh create stage
trigger-create-p:
	@./bin/triggers.sh create prod

.PHONY: trigger-run-d trigger-run-s trigger-run-p
trigger-run-d:
	@./bin/triggers.sh run dev
trigger-run-s:
	@./bin/triggers.sh run stage
trigger-run-p:
	@./bin/triggers.sh run prod

.PHONY: deploy
deploy:
	@./bin/triggers.sh run $(LIFECYCLE)

.PHONY: deploy-d deploy-s deploy-p
deploy-d: ; @$(MAKE) deploy LIFECYCLE=dev
deploy-s: ; @$(MAKE) deploy LIFECYCLE=stage
deploy-p: ; @$(MAKE) deploy LIFECYCLE=prod

.PHONY: deploy-ep
deploy-ep:
	@./bin/triggers.sh run-ep $(BRANCH)

.PHONY: check-ep
check-ep:
	@LC=$$(bash -c '. ./app.sh && lifecycle_from_branch "$(BRANCH)"'); \
	  $(MAKE) check LIFECYCLE=$$LC

.PHONY: secrets-ep
secrets-ep:
	@LC=$$(bash -c '. ./app.sh && lifecycle_from_branch "$(BRANCH)"'); \
	  $(MAKE) secrets LIFECYCLE=$$LC

.PHONY: trigger-describe
trigger-describe:
	@./bin/triggers.sh describe $(LIFECYCLE)


# ⎈ Helm
.PHONY: helm
helm: helm-status helm-values helm-history

.PHONY: helm-status
helm-status:
	@echo "⎈ Helm status for $(NAMESPACE)..."
	@./bin/helm.sh $(LIFECYCLE) status

.PHONY: helm-values
helm-values:
	@echo "⎈ Helm values for $(NAMESPACE)..."
	@./bin/helm.sh $(LIFECYCLE) values

.PHONY: helm-history
helm-history:
	@echo "⎈ Helm history for $(NAMESPACE)..."
	@./bin/helm.sh $(LIFECYCLE) history

.PHONY: helm-upgrade
helm-upgrade:
	@echo "⎈ Upgrading helm release $(NAMESPACE)..."
	@./bin/helm.sh $(LIFECYCLE) upgrade

.PHONY: helm-upgrade-d helm-upgrade-s helm-upgrade-p
helm-upgrade-d: ; @$(MAKE) helm-upgrade LIFECYCLE=dev
helm-upgrade-s: ; @$(MAKE) helm-upgrade LIFECYCLE=stage
helm-upgrade-p: ; @$(MAKE) helm-upgrade LIFECYCLE=prod


# Force ESO ExternalSecret resync
.PHONY: eso-sync
eso-sync:
	@echo "🔄 Forcing ESO resync in $(NAMESPACE)..."
	@./bin/cluster.sh $(LIFECYCLE) > /dev/null
	@kubectl annotate externalsecret app-secrets force-sync=$$(date +%s) -n $(NAMESPACE) --overwrite

.PHONY: eso-sync-d eso-sync-s eso-sync-p
eso-sync-d: ; @$(MAKE) eso-sync LIFECYCLE=dev
eso-sync-s: ; @$(MAKE) eso-sync LIFECYCLE=stage
eso-sync-p: ; @$(MAKE) eso-sync LIFECYCLE=prod


# 🔐 Secrets
.PHONY: secrets
secrets: list-secrets

.PHONY: list-secrets
list-secrets:
	@echo "🔐 Listing secrets in $(NAMESPACE)..."
	@./bin/secrets.sh $(LIFECYCLE) list

.PHONY: secrets-d secrets-s secrets-p
secrets-d: ; @$(MAKE) list-secrets LIFECYCLE=dev
secrets-s: ; @$(MAKE) list-secrets LIFECYCLE=stage
secrets-p: ; @$(MAKE) list-secrets LIFECYCLE=prod

.PHONY: get-secret
get-secret:
	@echo "🔐 Getting $(KEY) from $(NAMESPACE)..."
	@./bin/secrets.sh $(LIFECYCLE) get $(KEY)

.PHONY: add-secret
add-secret:
	@echo "🔐 Adding secret to $(NAMESPACE)..."
	@./bin/secrets.sh $(LIFECYCLE) add

.PHONY: eso-status
eso-status:
	@./bin/secrets.sh $(LIFECYCLE) eso-status

.PHONY: eso-status-d eso-status-s eso-status-p
eso-status-d: ; @$(MAKE) eso-status LIFECYCLE=dev
eso-status-s: ; @$(MAKE) eso-status LIFECYCLE=stage
eso-status-p: ; @$(MAKE) eso-status LIFECYCLE=prod

.PHONY: secretstore-sync
secretstore-sync:
	@./bin/secrets.sh $(LIFECYCLE) secretstore-sync

.PHONY: secretstore-sync-d secretstore-sync-s secretstore-sync-p
secretstore-sync-d: ; @$(MAKE) secretstore-sync LIFECYCLE=dev
secretstore-sync-s: ; @$(MAKE) secretstore-sync LIFECYCLE=stage
secretstore-sync-p: ; @$(MAKE) secretstore-sync LIFECYCLE=prod

.PHONY: env-pull
env-pull:
	@echo "🔐 Pulling dev secrets into src/api/.envs/.env.dev..."
	@./bin/env-pull.sh $(LIFECYCLE)

.PHONY: env-push
env-push:
	@echo "🔐 Pushing secrets from src/api/.envs/.env.$(LIFECYCLE) to $(APP_PROJECT)..."
	@./bin/env-push.sh $(LIFECYCLE)

.PHONY: secret-clean
secret-clean:
	@echo "🔐 Cleaning unused secrets from $(NAMESPACE)..."
	@./bin/secret-clean.sh $(LIFECYCLE)


# 📊 Status & Debugging
.PHONY: status
status:
	@echo "📊 Status of $(NAMESPACE)..."
	@./bin/status.sh $(LIFECYCLE) all

.PHONY: pods
pods:
	@echo "📊 Pods in $(NAMESPACE)..."
	@./bin/status.sh $(LIFECYCLE) pods

.PHONY: logs
logs:
	@echo "📊 Tailing API logs in $(NAMESPACE)..."
	@./bin/status.sh $(LIFECYCLE) logs

.PHONY: status-d status-s status-p
status-d: ; @$(MAKE) status LIFECYCLE=dev
status-s: ; @$(MAKE) status LIFECYCLE=stage
status-p: ; @$(MAKE) status LIFECYCLE=prod

.PHONY: dns-check
dns-check:
	@./bin/status.sh $(LIFECYCLE) dns-check

.PHONY: dns-check-d dns-check-s dns-check-p
dns-check-d: ; @$(MAKE) dns-check LIFECYCLE=dev
dns-check-s: ; @$(MAKE) dns-check LIFECYCLE=stage
dns-check-p: ; @$(MAKE) dns-check LIFECYCLE=prod

.PHONY: pods-d pods-s pods-p
pods-d: ; @$(MAKE) pods LIFECYCLE=dev
pods-s: ; @$(MAKE) pods LIFECYCLE=stage
pods-p: ; @$(MAKE) pods LIFECYCLE=prod

.PHONY: images
images:
	@echo "🐳 Building api image..."
	@DOCKER_BUILDKIT=1 docker build -t $(APP_CODE)/api:local ./src/api
	@echo "🐳 Building react image..."
	@DOCKER_BUILDKIT=1 docker build -t $(APP_CODE)/react:local ./src/react

.PHONY: check-images
check-images:
	@echo "📦 Pod images in $(NAMESPACE)..."
	@./bin/status.sh $(LIFECYCLE) check-images

.PHONY: check-images-d check-images-s check-images-p
check-images-d: ; @$(MAKE) check-images LIFECYCLE=dev
check-images-s: ; @$(MAKE) check-images LIFECYCLE=stage
check-images-p: ; @$(MAKE) check-images LIFECYCLE=prod

.PHONY: logs-d logs-s logs-p
logs-d: ; @$(MAKE) logs LIFECYCLE=dev
logs-s: ; @$(MAKE) logs LIFECYCLE=stage
logs-p: ; @$(MAKE) logs LIFECYCLE=prod


# 🔄 Rollout
.PHONY: restart
restart: restart-api restart-nginx

.PHONY: restart-api
restart-api:
	@echo "🔄 Restarting API in $(NAMESPACE)..."
	@./bin/rollout.sh $(LIFECYCLE) restart api

.PHONY: restart-nginx
restart-nginx:
	@echo "🔄 Restarting Nginx in $(NAMESPACE)..."
	@./bin/rollout.sh $(LIFECYCLE) restart nginx

.PHONY: scale
scale:
	@echo "🔄 Scaling $(DEPLOY) to $(REPLICAS) in $(NAMESPACE)..."
	@./bin/rollout.sh $(LIFECYCLE) scale $(DEPLOY) $(REPLICAS)


# 🐚 Exec
.PHONY: exec
exec:
	@echo "🐚 Exec into $(POD) in $(NAMESPACE)..."
	@./bin/kexec.sh $(LIFECYCLE) $(POD)
