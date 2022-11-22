NAMESPACE ?= octoperf
HELM_REPO=https://helm.octoperf.com

%.dependency-update:
	helm dependency update ./$*

%.package:
	helm package ./$*

%.lint:
	helm lint ./$*

%.debug:
	helm install --debug --dry-run --namespace $(NAMESPACE) $* ./$* > debug.log

# helm repo add octoperf https://myuser:mypass@helm.octoperf.com
%.push: %.package
	-helm plugin install https://github.com/chartmuseum/helm-push
	helm cm-push $*/ octoperf --force
	rm *.tgz
