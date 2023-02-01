default: dependencies

lint:
	helm lint

dependencies:
	rm -f requirements.lock && helm dependency build
