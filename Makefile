RUN := $(if $(shell command -v mise 2>/dev/null),mise exec --,)

.PHONY: setup dev check test e2e build
setup:
	$(RUN) bin/setup --skip-server
dev:
	$(RUN) bin/dev
check:
	$(RUN) bin/ci
test:
	$(RUN) bin/rails test
e2e:
	$(RUN) bin/rails test:system
build:
	$(RUN) bin/rails assets:precompile
