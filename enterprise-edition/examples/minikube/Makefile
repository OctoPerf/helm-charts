default: dry-run

NAMESPACE=octoperf
RELEASE ?= enterprise-edition
HELM_PARAMS=-f values.yaml $(RELEASE) --namespace $(NAMESPACE)

configure:
	minikube addons enable default-storageclass
	minikube addons enable storage-provisioner
	helm repo add traefik https://traefik.github.io/charts --force-update
	helm upgrade --install traefik traefik/traefik -n traefik --create-namespace -f traefik-values.yaml --wait --timeout 180s

dry-run:
	helm install $(HELM_PARAMS) --dry-run --debug ../../

start:
	minikube start

tunnel:
	minikube tunnel

debug:
	helm template --debug ../../

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

%.logs:
	kubectl -n $(NAMESPACE) logs -f pod/enterprise-edition-$*-0

events:
	kubectl -n $(NAMESPACE) get events --sort-by='.metadata.creationTimestamp' -A

delete-pvc:
	kubectl -n $(NAMESPACE) delete pvc --all 
