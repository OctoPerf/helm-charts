default: dry-run

NAMESPACE=octoperf
RELEASE ?= kubernetes-agent
HELM_PARAMS=-f values.yaml $(RELEASE) --namespace $(NAMESPACE)

configure:
	minikube addons enable metrics-server

dry-run:
	helm install $(HELM_PARAMS) --dry-run --debug ../../

start:
	minikube start

install: configure
	helm install $(HELM_PARAMS) --create-namespace ../../

get-all:
	kubectl -n $(NAMESPACE) get all

uninstall:
	helm uninstall $(RELEASE) -n $(NAMESPACE)

stop:
	minikube stop

delete-minikube:
	minikube delete

logs:
	kubectl -n $(NAMESPACE) logs -f pod/kubernetes-agent

events:
	kubectl -n $(NAMESPACE) get events --sort-by='.metadata.creationTimestamp' -A