include node_modules/make-livescript/livescript.mk

.PHONY: publish
publish: all
	npm publ