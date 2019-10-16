NAMESPACE=octoperf
CHART ?= enterprise-edition
HELM_PARAMS=-f values.yaml --name $(CHART) --namespace $(NAMESPACE)

HELM_REPO="https://helm.octoperf.com"

all:
	kubectl -n octoperf get all

package:
	helm package $(HELM_PARAMS) ./$(CHART)

install:
	helm install $(HELM_PARAMS) ./$(CHART)

upgrade:
	helm upgrade $(HELM_PARAMS) ./$(CHART)

push:
	helm plugin install https://github.com/chartmuseum/helm-push
	helm push --force $(CHART)/ octoperf