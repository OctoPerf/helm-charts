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
	helm delete $(NAME); true
	kubectl delete namespace $(NAMESPACE); true
	kubectl delete ClusterRole $(NAME)-runtime; true
	kubectl delete ClusterRoleBinding $(NAME)-runtime; true
	kubectl delete PodSecurityPolicy $(NAME)-grafana $(NAME)-grafana-test; true
	kubectl delete ClusterRole $(NAME)-grafana-clusterrole; true
	kubectl delete ClusterRoleBinding $(NAME)-grafana-clusterrolebinding; true