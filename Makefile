PREFIX = /usr

SHELL := sh

.PHONY: \
	install uninstall setup remove all backup \
	setup-shared setup-crypto-part setup-secboot-part setup-hosts-part \
	setup-aurtool-part remove-shared remove-crypto remove-hosts remove-secboot \
	remove-aurtool bkp-tool


install: setup
uninstall: remove
remove: remove-crypto remove-hosts remove-secboot remove-aurtool remove-shared
setup-crypto: setup-shared setup-crypto-part
setup-secboot: setup-shared setup-secboot-part
setup-hosts: setup-shared setup-hosts-part
setup-aurtool: setup-shared setup-aurtool-part
setup: setup-shared setup-crypto-part setup-hosts-part setup-secboot-part setup-aurtool-part
all: setup

setup-shared:
	install -d -m 755 $(PREFIX)/lib/dystopian-tools
	install -m 640 lib/variables.sh $(PREFIX)/lib/dystopian-tools/variables.sh
	install -m 640 lib/helper.sh $(PREFIX)/lib/dystopian-tools/helper.sh

	install -d -m 755 $(PREFIX)/share/doc/dystopian-tools
	install -m 644 README.md $(PREFIX)/share/doc/dystopian-tools/README.md

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
	install -m 640 lib/crypto-db.sh $(PREFIX)/lib/dystopian-tools/crypto-db.sh
	install -m 640 lib/ssl.sh $(PREFIX)/lib/dystopian-tools/ssl.sh
	install -m 640 lib/gpg.sh $(PREFIX)/lib/dystopian-tools/gpg.sh

setup-secboot-part:
	install -m 750 bin/dystopian-secboot $(PREFIX)/bin/dystopian-secboot
	install -d -m 700 /etc/dystopian-secboot
	install -d -m 700 /etc/dystopian-secboot/ms
	install -m 600 conf/secboot-db.json /etc/dystopian-secboot/secboot-db.json
	install -m 640 lib/secboot-db.sh $(PREFIX)/lib/dystopian-tools/secboot-db.sh
	install -m 640 lib/secboot.sh $(PREFIX)/lib/dystopian-tools/secboot.sh

setup-hosts-part:
	install -m 750 bin/dystopian-hosts $(PREFIX)/bin/dystopian-hosts
	install -d -m 755 /etc/dystopian-hosts
	install -m 600 conf/hosts-db.json /etc/dystopian-hosts/hosts-db.json
	install -m 640 lib/crypto-db.sh $(PREFIX)/lib/dystopian-tools/hosts-db.sh
	install -m 640 lib/hosts.sh $(PREFIX)/lib/dystopian-tools/hosts.sh

setup-aurtool-part:
	install -m 750 bin/dystopian-aurtool $(PREFIX)/bin/dystopian-aurtool
	install -d -m 755 /etc/dystopian-aurtool
	install -m 600 conf/aurtool-db.json /etc/dystopian-aurtool/aurtool-db.json
	install -m 640 lib/aurtool-db.sh $(PREFIX)/lib/dystopian-tools/aurtool-db.sh
	install -m 640 lib/aurtool.sh $(PREFIX)/lib/dystopian-tools/aurtool.sh

remove-shared:
	rm -f $(PREFIX)/lib/dystopian-tools/variables.sh
	rm -f $(PREFIX)/lib/dystopian-tools/helper.sh
	rm -f $(PREFIX)/lib/dystopian-tools/ssl.sh
	rm -f $(PREFIX)/lib/dystopian-tools/gpg.sh
	rm -f $(PREFIX)/lib/dystopian-tools/secboot.sh
	rm -f $(PREFIX)/lib/dystopian-tools/crypto-db.sh
	rm -f $(PREFIX)/lib/dystopian-tools/secboot-db.sh
	rm -f $(PREFIX)/lib/dystopian-tools/hosts.sh
	rmdir $(PREFIX)/lib/dystopian-tools || true
	rm -f $(PREFIX)/share/doc/dystopian-tools/README.md
	rmdir $(PREFIX)/share/doc/dystopian-tools || true

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

remove-hosts: SRC = dystopian-hosts
remove-hosts: bkp-tool
remove-hosts:
	rm -f $(PREFIX)/bin/dystopian-hosts
	rm -f $(PREFIX)/lib/dystopian-tools/hosts-db.sh
	rm -f /etc/dystopian-hosts/hosts-db.json
	rmdir /etc/dystopian-hosts || true

remove-aurtool: SRC = dystopian-aurtool
remove-aurtool: bkp-tool
remove-aurtool:
	rm -f $(PREFIX)/bin/dystopian-aurtool
	rm -f $(PREFIX)/lib/dystopian-tools/aurtool-db.sh
	rm -f /etc/dystopian-aurtool/aurtool-db.json
	rmdir /etc/dystopian-aurtool || true

bkp-tool:
	@set -eu; \
	. $(PREFIX)/lib/dystopian-tools/variables.sh; \
	. $(PREFIX)/lib/dystopian-tools/helper.sh; \
	: "$${SRC:?Set SRC to a directory name (e.g. dystopian-crypto) or absolute path}"; \
	case "$$SRC" in \
		/*) _path="$$SRC" ;; \
		*)  _path="/etc/$$SRC" ;; \
	esac; \
	backup_targz "$$_path"
