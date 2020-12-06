HOST=

ifndef HOST
$(error hostname must be defined using HOST=hostname)
endif

VMS=$(realpath vms)
CONFIG=$(realpath config)
IMAGES=$(realpath images)

BASE_IMG=$(IMAGES)/Fedora-Cloud-Base-33-1.2.x86_64.qcow2

DIR=$(VMS)/$(HOST)
DRIVE=$(DIR)/drive.qcow2
BASE_IMG_PATH=$(shell realpath --relative-to $(DIR) $(BASE_IMG))
SEED=$(DIR)/seed.iso
CONFIG_XML=$(DIR)/config.xml

all: $(DRIVE) $(SEED) $(CONFIG_XML)

$(DIR):
	mkdir $@

$(DRIVE): | $(DIR)
	qemu-img create -f qcow2 -b $(BASE_IMG_PATH) $@ 20G

$(SEED): | $(DIR)
	$(CONFIG)/seed.sh $(HOST) $@

$(CONFIG_XML): | $(DIR)
	host=$(HOST) \
	drive=$(DRIVE) \
	seed=$(SEED) \
	envsubst < $(CONFIG)/template.xml > $@




# sed -e 's|@host|$(HOST)|' \
#		-e 's|@drive|$(realpath $(DRIVE))|' \
#		-e 's|@seed|$(realpath $(SEED))|' \
#		$(CONFIG)/template.xml > $@
