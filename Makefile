HOST=

ifndef HOST
$(error hostname must be defined using HOST=hostname)
endif

VMS=$(realpath vms)
CONFIG=$(realpath config)
IMAGES=$(realpath images)

BASE_IMG=$(IMAGES)/Fedora-Cloud-Base-33-1.2.x86_64.qcow2
SSH_KEY=$(shell cat ~/.ssh/id_rsa.pub)

DIR=$(VMS)/$(HOST)
DRIVE=$(DIR)/drive.qcow2
BASE_IMG_PATH=$(shell realpath --relative-to $(DIR) $(BASE_IMG))
CONFIG_XML=$(DIR)/config.xml
SEED=$(DIR)/seed.iso
TEMP=$(DIR)/.temp
META_DATA=$(TEMP)/meta-data
USER_DATA=$(TEMP)/user-data

export HOST DRIVE SEED SSH_KEY

all: $(DRIVE) $(SEED) $(CONFIG_XML)

$(TEMP):
	mkdir -p $@

$(DIR):
	mkdir $@

$(DRIVE): | $(DIR)
	qemu-img create -F qcow2 -b $(BASE_IMG_PATH) -f qcow2 $@ 20G

$(USER_DATA): | $(TEMP)
	envsubst < $(CONFIG)/user-data > $@

$(META_DATA): | $(TEMP)
	envsubst < $(CONFIG)/meta-data > $@

$(SEED): $(USER_DATA) $(META_DATA) | $(DIR)
	genisoimage -output $@ \
		-input-charset UTF-8 \
		-volid cidata \
		-joliet -rock \
		$^

$(CONFIG_XML): | $(DIR)
	envsubst < $(CONFIG)/template.xml > $@
