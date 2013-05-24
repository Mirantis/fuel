ISOLINUX_FILES:=boot.msg grub.conf initrd.img isolinux.bin memtest splash.jpg vesamenu.c32 vmlinuz
IMAGES_FILES:=efiboot.img efidisk.img install.img
EFI_FILES:=BOOTX64.conf BOOTX64.efi splash.xpm.gz
PUPPET_FILES:=puppet-2.7.19-1.el6.noarch.rpm puppet-server-2.7.19-1.el6.noarch.rpm puppet-3.0.1-1.el6.noarch.rpm puppet-server-3.0.1-1.el6.noarch.rpm
# centos isolinux files
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/isolinux/,$(ISOLINUX_FILES)):
	@mkdir -p $(@D)
	wget -O $@ $(MIRROR_CENTOS_OS_BASEURL)/isolinux/$(@F)

# centos EFI boot images
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/EFI/BOOT/,$(EFI_FILES)):
	@mkdir -p $(@D)
	wget -O $@ $(MIRROR_CENTOS_OS_BASEURL)/EFI/BOOT/$(@F)

# centos boot images
$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/images/,$(IMAGES_FILES)):
	@mkdir -p $(@D)
	wget -O $@ $(MIRROR_CENTOS_OS_BASEURL)/images/$(@F)

# centos puppet 2.7
$(BUILD_DIR)/mirror/puppet-rpms.done:
	@mkdir -p $(LOCAL_MIRROR)/Packages
	for rpmfile in $(PUPPET_FILES); do \
	  wget -O $(LOCAL_MIRROR)/Packages/$$rpmfile $(MIRANTIS_MIRROR)/noarch/$$rpmfile; \
	done
	$(ACTION.TOUCH)

$(BUILD_DIR)/mirror/boot.done: \
		$(addprefix $(LOCAL_MIRROR_CENTOS_OS_BASEURL)/isolinux/,$(ISOLINUX_FILES))
	$(ACTION.TOUCH)

$(BUILD_DIR)/mirror/ubuntu-netboot.done: \
		$(LOCAL_MIRROR)/ubuntu/netboot/linux \
		$(LOCAL_MIRROR)/ubuntu/netboot/initrd.gz
	$(ACTION.TOUCH)

$(LOCAL_MIRROR)/ubuntu/netboot/linux:
	mkdir -p $(@D)
	wget -O $@ $(MIRROR_UBUNTU_OS_BASEURL)/installer-$(UBUNTU_ARCH)/current/images/netboot/ubuntu-installer/$(UBUNTU_ARCH)/$(@F)

$(LOCAL_MIRROR)/ubuntu/netboot/initrd.gz:
	mkdir -p $(@D)
	wget -O $@ $(MIRROR_UBUNTU_OS_BASEURL)/installer-$(UBUNTU_ARCH)/current/images/netboot/ubuntu-installer/$(UBUNTU_ARCH)/$(@F)
