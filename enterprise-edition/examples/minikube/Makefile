default: dry-run

NAMESPACE=octoperf
RELEASE ?= enterprise-edition
HELM_PARAMS=-f values.yaml --name $(RELEASE) --namespace $(NAMESPACE)

dry-run:
	helm install $(HELM_PARAMS) --dry-run --debug ../../

install:
	helm install $(HELM_PARAMS) ../../

get-all:
	kubectl -n octoperf get all

purge:
	helm del --purge $(RELEASE)

clean:
	-helm delete $(RELEASE)
	-helm del --purge $(RELEASE)
