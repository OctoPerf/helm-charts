NAMESPACE=octoperf
CHART ?= enterprise-edition
HELM_PARAMS=--name $(CHART) --namespace $(NAMESPACE)

HELM_REPO="https://helm.octoperf.com"

dependency-update:
	helm dependency update ./$(CHART)

package:
	helm package ./$(CHART)

push:
	-helm plugin install https://github.com/chartmuseum/helm-push
	helm push --force $(CHART)/ octoperf