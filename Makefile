PREFIX = /usr

SHELL := sh

.PHONY: \
	install uninstall setup remove all backup \
	setup-crypto-part setup-secboot-part \
	remove-crypto remove-secboot bkp-tool


install: setup
uninstall: remove
remove: remove-crypto remove-secboot
setup-crypto: setup-crypto-part
setup-secboot: setup-secboot-part
setup: setup-crypto-part setup-secboot-part
all: setup

setup-crypto-part:
	install -m 750 bin/dystopian-crypto $(PREFIX)/bin/dystopian-crypto
	install -d -m 755 /etc/dystopian-crypto
	install -d -m 755 /etc/dystopian-crypto/ca
	install -d -m 750 /etc/dystopian-crypto/ca/private
	install -d -m 755 /etc/dystopian-crypto/cert
	install -d -m 750 /etc/dystopian-crypto/cert/private
	install -d -m 750 /etc/dystopian-crypto/old
	install -d -m 700 /etc/dystopian-crypto/gnupg
	install -d -m 755 /etc/dystopian-crypto/crl
	install -m 600 conf/crypto-db.json /etc/dystopian-crypto/crypto-db.json

setup-secboot-part:
	install -m 750 bin/dystopian-secboot $(PREFIX)/bin/dystopian-secboot
	install -d -m 700 /etc/dystopian-secboot
	install -d -m 700 /etc/dystopian-secboot/ms
	install -m 600 conf/secboot-db.json /etc/dystopian-secboot/secboot-db.json

remove-crypto: SRC = dystopian-crypto
remove-crypto: bkp-tool
remove-crypto:
	rm -f $(PREFIX)/bin/dystopian-crypto
	rm -f /etc/dystopian-crypto/crypto-db.json
	rmdir /etc/dystopian-crypto/ca/private || true
	rmdir /etc/dystopian-crypto/ca || true
	rmdir /etc/dystopian-crypto/cert/private || true
	rmdir /etc/dystopian-crypto/cert || true
	rmdir /etc/dystopian-crypto/old || true
	rm -f /etc/dystopian-crypto/gnupg/*
	rmdir /etc/dystopian-crypto/gnupg || true
	rmdir /etc/dystopian-crypto/crl || true
	rmdir /etc/dystopian-crypto || true

remove-secboot: SRC = dystopian-secboot
remove-secboot: bkp-tool
remove-secboot:
	rm -f $(PREFIX)/bin/dystopian-secboot
	rm -f /etc/dystopian-secboot/secboot-db.json
	rmdir /etc/dystopian-secboot/ms || true
	rmdir /etc/dystopian-secboot || true

bkp-tool:
	@set -eu; \
	. $(PREFIX)/lib/dystopian-lib/libtools-variables.sh; \
	. $(PREFIX)/lib/dystopian-lib/libtools-helper.sh; \
	: "$${SRC:?Set SRC to a directory name (e.g. dystopian-crypto) or absolute path}"; \
	case "$$SRC" in \
		/*) _path="$$SRC" ;; \
		*)  _path="/etc/$$SRC" ;; \
	esac; \
	backup_targz "$$_path"
