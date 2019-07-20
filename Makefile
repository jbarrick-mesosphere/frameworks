KUDO_VERSION=0.3.2
KUBERNETES_VERSION=1.14.2

OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')

KUDO_MACHINE=$(shell uname -m)
MACHINE=$(shell uname -m)
ifeq "$(MACHINE)" "x86_64"
  MACHINE=amd64
endif

bin/:
	mkdir -p bin/

bin/kubectl_$(KUBERNETES_VERSION): bin/
	curl -Lo bin/kubectl_$(KUBERNETES_VERSION) https://storage.googleapis.com/kubernetes-release/release/v$(KUBERNETES_VERSION)/bin/$(OS)/$(MACHINE)/kubectl
	chmod +x bin/kubectl_$(KUBERNETES_VERSION)

bin/kubectl-kudo_$(KUDO_VERSION): bin/
	curl -Lo bin/kubectl-kudo_$(KUDO_VERSION) https://github.com/kudobuilder/kudo/releases/download/v$(KUDO_VERSION)/kubectl-kudo_$(KUDO_VERSION)_$(OS)_$(KUDO_MACHINE)
	chmod +x bin/kubectl-kudo_$(KUDO_VERSION)

bin/kubectl: bin/kubectl_$(KUBERNETES_VERSION)
	cp bin/kubectl_$(KUBERNETES_VERSION) bin/kubectl

bin/kubectl-kudo: bin/kubectl-kudo_$(KUDO_VERSION)
	cp bin/kubectl-kudo_$(KUDO_VERSION) bin/kubectl-kudo

test/crds/kudo_$(KUDO_VERSION).yaml:
	rm -rf test/crds/
	mkdir -p test/crds/
	curl -Lo test/crds/kudo_$(KUDO_VERSION).yaml https://raw.githubusercontent.com/kudobuilder/kudo/v$(KUDO_VERSION)/docs/deployment/10-crds.yaml

.PHONY: setup
setup: bin/kubectl bin/kubectl-kudo test/crds/kudo_$(KUDO_VERSION).yaml

.PHONY: test
test: setup
	./bin/kubectl-kudo test --kind-config test/kind/v$(KUBERNETES_VERSION).yaml
