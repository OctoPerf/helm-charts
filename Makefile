NAMESPACE=octoperf
CHART ?= enterprise-edition
HELM_PARAMS=-f values.yaml --name $(CHART) --namespace $(NAMESPACE)

HELM_REPO="https://helm.octoperf.com"

all:
	kubectl -n octoperf get all

install:
	helm install $(HELM_PARAMS) ./$(CHART)

upgrade:
	helm upgrade $(HELM_PARAMS) ./$(CHART)

push:
	helm push --force $(CHART)/ octoperf