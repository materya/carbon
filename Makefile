#!make

ifneq (,$(wildcard .env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

PM = npm
RM = rm

PRERELEASE_TAG ?= beta
PUBLISH_FLAGS = publish --access public

MODULES = node_modules
DIST = dist
COVERAGE = .nyc_output coverage

.PHONY: all
all: $(DIST)

$(ENVFILE):
	cp $(ENVFILE).defaults $(ENVFILE)

$(MODULES):
	$(PM) ci

$(DIST): $(ENV) $(MODULES)
	$(PM) run build

.PHONY: clean
clean:
	$(RM) -rf $(DIST) $(COVERAGE)

.PHONY: clean-all
clean-all:
	$(RM) -rf $(MODULES)

.PHONY: test
test: $(MODULES)
	$(PM) t

coverage:
	$(PM) run coverage

.PHONY: release
release: clean all
ifneq (,$(findstring n,$(MAKEFLAGS)))
	+$(PM) run release -- --dry-run
	+$(PM) $(PUBLISH_FLAGS) --dry-run
else
	$(PM) run release
	git push --follow-tags origin main
	$(PM) $(PUBLISH_FLAGS)
endif

.PHONY: prerelease
prerelease: clean all
ifneq (,$(findstring n,$(MAKEFLAGS)))
	+$(PM) run release -- --prerelease $(PRERELEASE_TAG) --dry-run
	+$(PM) $(PUBLISH_FLAGS) --tag $(PRERELEASE_TAG) --dry-run
else
	$(PM) run release -- --prerelease $(PRERELEASE_TAG)
	git push --follow-tags origin main
	$(PM) $(PUBLISH_FLAGS) --tag $(PRERELEASE_TAG)
endif
