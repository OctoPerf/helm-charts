default: dry-run

NAMESPACE=octoperf
RELEASE ?= enterprise-edition
HELM_PARAMS=-f values.yaml $(RELEASE) --namespace $(NAMESPACE)

configure:
	minikube addons enable ingress
	minikube addons enable default-storageclass
	minikube addons enable storage-provisioner

dry-run:
	helm install $(HELM_PARAMS) --dry-run --debug ../../

start:
	minikube start

install: configure start
	helm install $(HELM_PARAMS) --create-namespace ../../

get-all:
	kubectl -n $(NAMESPACE) get all

uninstall:
	helm uninstall $(RELEASE) -n $(NAMESPACE)

stop:
	minikube stop

get-all:
	kubectl -n octoperf get all
