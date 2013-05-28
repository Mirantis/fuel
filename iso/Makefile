# Use make iso ISO_METHOD=pungi to use ks-full.cfg and pungi for build (works only on 172.16.0.19)
TOP_DIR?=$(PWD)
TOP_DIR:=$(abspath $(TOP_DIR))

COMMIT_SHA:=$(shell git rev-parse --verify HEAD)
FUEL_VERSION:=2.2-folsom

CENTOS_MAJOR:=6
CENTOS_MINOR:=4
CENTOS_RELEASE:=$(CENTOS_MAJOR).$(CENTOS_MINOR)
CENTOS_ARCH:=x86_64

UBUNTU_DISTR:=precise
UBUNTU_ARCH:=amd64
UBUNTU_COMP:=main

FUEL_DIR:=$(PWD)/../deployment/puppet
SOURCE_DIR:=$(PWD)
BUILD_DIR?=$(PWD)/build

LOCAL_MIRROR:=$(PWD)/../../local_mirror
LOCAL_MIRROR_CENTOS:=$(LOCAL_MIRROR)/centos
LOCAL_MIRROR_CENTOS_OS_BASEURL:=$(LOCAL_MIRROR_CENTOS)/$(CENTOS_RELEASE)/os/$(CENTOS_ARCH)
LOCAL_MIRROR_UBUNTU:=$(LOCAL_MIRROR)/ubuntu/dists/$(UBUNTU_DISTR)
LOCAL_MIRROR_UBUNTU_DEB:=$(LOCAL_MIRROR_UBUNTU)/$(UBUNTU_COMP)/binary-$(UBUNTU_ARCH)
LOCAL_MIRROR_UBUNTU_INSTALLER:=$(LOCAL_MIRROR_UBUNTU)/$(UBUNTU_COMP)/debian-installer/binary-$(UBUNTU_ARCH)
MIRANTIS_MIRROR?=http://srv08-srt.srt.mirantis.net/centos-repo/epel-fuel-folsom-2.1/
MIRROR_CENTOS:=http://srv11-msk.msk.mirantis.net/centos-repo/centos-6.4/
MIRROR_CENTOS_UPDATES:=http://srv11-msk.msk.mirantis.net/centos-repo/centos-6.4-updates/
#MIRROR_CENTOS:=http://archive.kernel.org/centos
MIRROR_CENTOS_OS_BASEURL:=$(MIRROR_CENTOS)
#MIRROR_CENTOS_OS_BASEURL:=$(MIRROR_CENTOS)/$(CENTOS_RELEASE)/os/$(CENTOS_ARCH)
MIRROR_UBUNTU:=http://mirror.yandex.ru/ubuntu
MIRROR_UBUNTU_OS_BASEURL:=$(MIRROR_UBUNTU)/dists/$(UBUNTU_DISTR)/$(UBUNTU_COMP)
YUM_REPOS:=centos epel fuel_folsom puppetlabs rpmforge

BUILDKS:=$(BUILD_DIR)/iso/ks-build.cfg
INSTALLKS:=$(SOURCE_DIR)/iso/ks.cfg

include $(SOURCE_DIR)/mirror/module.mk
include $(SOURCE_DIR)/ks_build.mk
include $(SOURCE_DIR)/yum_ks_repos.mk

clean:
	sudo rm -rf $(BUILD_DIR)
	sudo rm -rf $(LOCAL_MIRROR)/ubuntu/dists
	sudo rm -rf $(LOCAL_MIRROR)/ubuntu/etc
	sudo rm -rf $(LOCAL_MIRROR)/ubuntu/var

deep_clean: clean
	sudo rm -rf $(LOCAL_MIRROR)

.PHONY: iso clean
all: iso

ISOROOT:=$(BUILD_DIR)/iso/isoroot

#ifeq (foo, foo$(BUILD_ID))
#    BUILD_ID:=$(shell date +"%Y-%m-%d_%H-%M-%S")
#endif

ISOBASENAME:=fuel-centos-$(CENTOS_RELEASE)-$(CENTOS_ARCH)-$(FUEL_VERSION)
#[ -z "$$ISOSUFFIX" ] || ISOBASENAME:=$(ISOBASENAME)-$(ISOSUFFIX)
#ISOBASENAME:=fuel-centos-$(CENTOS_RELEASE)-$(CENTOS_ARCH)_$(BUILD_ID)

ISONAME:=$(BUILD_DIR)/iso/$(ISOBASENAME).iso

iso: $(ISONAME)

ifeq ($(ISO_METHOD), pungi)
$(BUILD_DIR)/iso/isoroot-os.done: \
		$(BUILD_DIR)/iso/isoroot-pungi.done 
	mkdir -p $(ISOROOT)/ubuntu
	rsync -rp $(LOCAL_MIRROR)/ubuntu/netboot $(ISOROOT)/ubuntu
	$(ACTION.TOUCH)
else
$(BUILD_DIR)/iso/isoroot-os.done: \
		$(BUILD_DIR)/mirror/build.done \
		$(BUILD_DIR)/iso/isoroot-dotfiles.done
	mkdir -p $(ISOROOT)/ubuntu
	rsync -rp $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/ $(ISOROOT)
	rsync -rp $(LOCAL_MIRROR)/ubuntu/netboot $(ISOROOT)/ubuntu
	$(ACTION.TOUCH)
endif

$(BUILD_DIR)/iso/isoroot-pungi.done: $(BUILD_DIR)/iso/kickstart.done
	[ -d $(BUILD_DIR)/iso/`date +%Y%m%d`/x86_64/os-disc1 ] && sudo rm -rf $(BUILD_DIR)/iso/`date +%Y%m%d`/x86_64/os-disc1 || :
	if [ -f $(BUILD_DIR)/iso/`date +%Y%m%d`/x86_64/os/images/install.img ];then \
	  echo "Reusing existing iso data (and saving time)...";\
	  sudo pungi -c $(BUILDKS) --nosplitmedia --name=fuel-$(FUEL_VERSION) --nosource --nodebuginfo -G -C -I --destdir $(BUILD_DIR)/iso/ --cachedir $(LOCAL_MIRROR) --force; \
	else \
	  echo "No existing iso data. Building from scratch (~15 minutes)..."; \
	  sudo pungi -c $(BUILDKS) --nosplitmedia --name=fuel-$(FUEL_VERSION) --nosource --nodebuginfo -G -C -I -B --destdir $(BUILD_DIR)/iso/ --cachedir $(LOCAL_MIRROR) --force; \
	fi
	mkdir -p mountiso $(ISOROOT)
	sudo mount -o loop,ro $(BUILD_DIR)/iso/`date +%Y%m%d`/x86_64/iso/fuel-*-x86_64-DVD.iso mountiso
	rsync -a --delete --exclude=isolinux/isolinux.cfg mountiso/. $(ISOROOT)/.
	chmod -R u+rw $(ISOROOT)
	sudo umount mountiso
	rm -rf mountiso
	sudo rm -rf $(BUILD_DIR)/iso/`date +%Y%m%d`/x86_64/iso/fuel-*-x86_64-DVD.iso
	$(ACTION.TOUCH)

$(BUILD_DIR)/iso/kickstart.done: $(BUILD_DIR)/iso/ksrepos.cfg $(BUILDKS)
$(BUILDKS): $(call depv,ks_build_cfg)
$(BUILDKS): export contents:=$(ks_build_cfg)
$(BUILDKS):
	mkdir -p $(@D)
	echo -e "$${contents}" > $@
$(BUILD_DIR)/iso/ksrepos.cfg: $(call depv,yum_ks_repos)
$(BUILD_DIR)/iso/ksrepos.cfg: export contents:=$(yum_ks_repos)
$(BUILD_DIR)/iso/ksrepos.cfg:
	mkdir -p $(@D)
	echo -e "$${contents}" > $@



$(BUILD_DIR)/iso/isoroot-dotfiles.done: \
		$(ISOROOT)/.discinfo \
		$(ISOROOT)/.treeinfo
	$(ACTION.TOUCH)

$(BUILD_DIR)/iso/isoroot-files.done: \
		$(BUILD_DIR)/iso/isoroot-dotfiles.done \
		$(ISOROOT)/isolinux/isolinux.cfg \
		$(ISOROOT)/ks.cfg \
		$(ISOROOT)/bootstrap_admin_node.sh \
		$(ISOROOT)/functions.sh \
		$(ISOROOT)/bootstrap_admin_node.conf \
		$(ISOROOT)/version.yaml \
		$(ISOROOT)/fuel-modules.tgz \
		$(ISOROOT)/astute-0.0.1.gem \
		$(ISOROOT)/Packages/rebuild
	$(ACTION.TOUCH)

$(ISOROOT)/fuel-modules.tgz: \
		$(call find-files,$(FUEL_DIR))
	(cd $(FUEL_DIR) && tar chzf $@ *)

$(ISOROOT)/astute-0.0.1.gem:
	mkdir -p $(@D)
	( cd $(SOURCE_DIR)/../deployment/mcollective/astute && gem build astute.gemspec )
	mv $(SOURCE_DIR)/../deployment/mcollective/astute/$(@F) $@

$(ISOROOT)/Packages/puppet-2.7.19-1.el6.noarch.rpm:
	mkdir -p $(@D)
	rsync -rp $(LOCAL_MIRROR)/Packages/$(@F) $(ISOROOT)/Packages/.
	$(ACTION.TOUCH)

$(ISOROOT)/Packages/puppet-server-2.7.19-1.el6.noarch.rpm:
	mkdir -p $(@D)
	rsync -rp $(LOCAL_MIRROR)/Packages/$(@F) $(ISOROOT)/Packages/.
	$(ACTION.TOUCH)

$(ISOROOT)/Packages/puppet-3.0.1-1.el6.noarch.rpm:
	mkdir -p $(@D)
	rsync -rp $(LOCAL_MIRROR)/Packages/$(@F) $(ISOROOT)/Packages/.
	$(ACTION.TOUCH)

$(ISOROOT)/Packages/puppet-server-3.0.1-1.el6.noarch.rpm:
	mkdir -p $(@D)
	rsync -rp $(LOCAL_MIRROR)/Packages/$(@F) $(ISOROOT)/Packages/.
	$(ACTION.TOUCH)

$(ISOROOT)/Packages/rebuild:
	[ ! -d $(ISOROOT)/Packages ] || ( cd $(ISOROOT) && createrepo -g repodata/*comps*.xml . )

$(ISOROOT)/.discinfo: $(SOURCE_DIR)/.discinfo ; $(ACTION.COPY)
$(ISOROOT)/.treeinfo: $(SOURCE_DIR)/.treeinfo ; $(ACTION.COPY)
$(ISOROOT)/isolinux/isolinux.cfg: $(SOURCE_DIR)/isolinux/isolinux.cfg ; $(ACTION.COPY)
ifeq ($(ISO_METHOD), pungi)
$(ISOROOT)/ks.cfg: 
	cp $(SOURCE_DIR)/ks-full.cfg $(ISOROOT)/ks.cfg
else
$(ISOROOT)/ks.cfg: $(SOURCE_DIR)/ks.cfg; $(ACTION.COPY)
	[ -z "$$TGTDRIVE" ] || sed -i "s/^\(tgtdrive=\)\".*\"$$/\1\"$$TGTDRIVE\"/" $@
	[ -z "$$USEEXTIF" ] || sed -i "s/^\(network\s*--bootproto=dhcp\.*\)/\1 --device=$$USEEXTIF/" $@
	[ -z "$$ISO_URL" ] || sed -i "s|^#\?url --url.*|url --url $$ISO_URL|" $@
	[ -z "$$BASE_MIRROR" ] || sed -i "s|^#\?repo --name=Base.*|repo --name=Base --mirrorlist=$$BASE_MIRROR|" $@
	[ -z "$$UPDATES_MIRROR" ] || sed -i "s|^#\?repo --name=Updates.*|repo --name=Updates --mirrorlist=$$UPDATES_MIRROR|" $@
	[ -z "$$MIRANTIS_MIRROR" ] || sed -i "s|^#\?repo --name=Mirantis.*|repo --name=Mirantis --mirrorlist=$$MIRANTIS_MIRROR|" $@
	[ -z "$$PUPPETLABS_MIRROR" ] || sed -i "s|^#\?repo --name=PuppetLabs.*|repo --name=PuppetLabs --mirrorlist=$$PUPPETLABS_MIRROR|" $@
endif
$(ISOROOT)/bootstrap_admin_node.sh: $(SOURCE_DIR)/bootstrap_admin_node.sh ; $(ACTION.COPY)
$(ISOROOT)/functions.sh: $(SOURCE_DIR)/functions.sh ; $(ACTION.COPY)
$(ISOROOT)/bootstrap_admin_node.conf: $(SOURCE_DIR)/bootstrap_admin_node.conf ; $(ACTION.COPY)
$(ISOROOT)/version.yaml: $(call depv,COMMIT_SHA)
$(ISOROOT)/version.yaml: $(call depv,FUEL_VERSION)
$(ISOROOT)/version.yaml:
	echo "COMMIT_SHA: $(COMMIT_SHA)" > $@
	echo "PRODUCT_VERSION: $(FUEL_VERSION)" >> $@

########################
# Iso image root file system.
########################

$(BUILD_DIR)/iso/isoroot.done: \
		$(BUILD_DIR)/mirror/build.done \
		$(BUILD_DIR)/iso/isoroot-os.done \
		$(BUILD_DIR)/iso/isoroot-files.done
	$(ACTION.TOUCH)


########################
# Building CD image
########################

# keep in mind that mkisofs touches some files inside directory
# from which it builds iso image
# that is why we need to make $/isoroot.done dependent on some files
# and then copy these files into another directory

$(ISONAME): $(BUILD_DIR)/iso/isoroot.done
	rm -f $@
	mkdir -p $(BUILD_DIR)/iso/isoroot-mkisofs
	rsync -a --delete $(ISOROOT)/ $(BUILD_DIR)/iso/isoroot-mkisofs
	mkisofs -r -V "Mirantis Fuel $(FUEL_VERSION)" -p "Mirantis Inc." \
		-joliet-long -T -R -b isolinux/isolinux.bin \
		-no-emul-boot \
		-boot-load-size 4 -boot-info-table \
		-x "lost+found" -o $@ $(BUILD_DIR)/iso/isoroot-mkisofs
	implantisomd5 $@


####################### FUNCTIONS #############################

define ACTION.COPY
@mkdir -p $(@D)
cp $< $@
endef

define ACTION.TOUCH
@mkdir -p $(@D)
touch $@
endef

define depv
$(shell mkdir -p $(DEPV_DIR))
$(shell echo "$($1)" > $(DEPV_DIR)/$1.tmp)
$(shell diff >/dev/null 2>&1 $(DEPV_DIR)/$1.tmp $(DEPV_DIR)/$1.dep \
	|| mv $(DEPV_DIR)/$1.tmp $(DEPV_DIR)/$1.dep)
$(DEPV_DIR)/$1.dep
endef

$(BUILD_DIR)/%/.dir:
	mkdir -p $(@D)
	@touch $@

find-files=$(shell test -d $1 && find $1 -type f 2> /dev/null)
