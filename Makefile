NAMESPACE ?= octoperf
CHART ?= enterprise-edition
HELM_PARAMS=--name $(CHART) --namespace $(NAMESPACE)
HELM_REPO="https://helm.octoperf.com"

default: debug

dependency-update:
	helm dependency update ./$(CHART)

package:
	helm package ./$(CHART)

lint:
	helm lint ./$(CHART)

debug:
	helm install --debug --dry-run --namespace $(NAMESPACE) $(CHART) ./$(CHART) > debug.log

push:
	-helm plugin install https://github.com/chartmuseum/helm-push
	helm push --force $(CHART)/ octoperf

install:
	kubectl create namespace $(NAMESPACE); true
	helm install --namespace $(NAMESPACE) $(CHART) ./$(CHART)

kraken-clean:
	helm delete $(CHART); true
	kubectl delete namespace $(NAMESPACE); true
	kubectl delete ClusterRole $(CHART)-runtime; true
	kubectl delete ClusterRoleBinding $(CHART)-runtime; true
	kubectl delete PodSecurityPolicy $(CHART)-grafana $(CHART)-grafana-test; true
	kubectl delete ClusterRole $(CHART)-grafana-clusterrole; true
	kubectl delete ClusterRoleBinding $(CHART)-grafana-clusterrolebinding; true