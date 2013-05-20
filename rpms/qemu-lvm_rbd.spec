Name: qemu-lvm_rbd
Version: 1
Release: 1
Source0: qemu-lvm_rbd-1.tar.gz
License: GPL
Group: ASD
BuildArch: x86_64
BuildRoot: %{_tmppath}/%{name}-buildroot
Summary: testing
%description
std qemu-kvm 1.2.50 whith rbd enabled for CentOS6.3
%prep
%setup -q
%build
%install
install -d -m 0755 "$RPM_BUILD_ROOT/usrl/share/qemu"
install -d -m 0755 "$RPM_BUILD_ROOT/usr/bin"
libtool --quiet --mode=install install -c -m 0755  qemu-ga qemu-nbd qemu-img qemu-io  "$RPM_BUILD_ROOT/usr/bin"
install -d -m 0755 "$RPM_BUILD_ROOT/usr/libexec"
libtool --quiet --mode=install install -c -m 0755  qemu-bridge-helper "$RPM_BUILD_ROOT/usr/libexec"
install -d -m 755 $RPM_BUILD_ROOT/usr/share/qemu
set -e; for x in bios.bin sgabios.bin vgabios.bin vgabios-cirrus.bin vgabios-stdvga.bin vgabios-vmware.bin vgabios-qxl.bin acpi-dsdt.aml q35-acpi-dsdt.aml ppc_rom.bin openbios-sparc32 openbios-sparc64 openbios-ppc pxe-e1000.rom pxe-eepro100.rom pxe-ne2k_pci.rom pxe-pcnet.rom pxe-rtl8139.rom pxe-virtio.rom efi-e1000.rom efi-eepro100.rom efi-ne2k_pci.rom efi-pcnet.rom efi-rtl8139.rom efi-virtio.rom qemu-icon.bmp bamboo.dtb petalogix-s3adsp1800.dtb petalogix-ml605.dtb multiboot.bin linuxboot.bin kvmvapic.bin s390-zipl.rom s390-ccw.img spapr-rtas.bin slof.bin palcode-clipper
do
    install -c -m 0644 pc-bios/$x "$RPM_BUILD_ROOT/usr/share/qemu"                                                                                                                                                          
done                                                                                                                                                                                                                                 
install -d -m 0755 "$RPM_BUILD_ROOT/usr/share/qemu/keymaps"                                                                                                                                                                                           
set -e; for x in da     en-gb  et  fr     fr-ch  is  lt  modifiers  no  pt-br  sv ar      de     en-us  fi  fr-be  hr     it  lv  nl         pl  ru     th common  de-ch  es     fo  fr-ca  hu     ja  mk  nl-be      pt  sl     tr bepo
do
    install -c -m 0644 pc-bios/keymaps/$x "$RPM_BUILD_ROOT/usr/share/qemu/keymaps"                                                                                                                                          
done
install -m 755 qemu-kvm "$RPM_BUILD_ROOT/usr/libexec"                                                                                                                                                                                                                                 
install -m 755 qemu-system-i386 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                             
install -m 755 qemu-system-x86_64 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                           
install -m 755 qemu-system-alpha "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-system-arm "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                              
install -m 755 qemu-system-cris "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                             
install -m 755 qemu-system-lm32 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                             
install -m 755 qemu-system-m68k "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                             
install -m 755 qemu-system-microblaze "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                       
install -m 755 qemu-system-microblazeel "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                     
install -m 755 qemu-system-mips "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                             
install -m 755 qemu-system-mipsel "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                           
install -m 755 qemu-system-mips64 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                           
install -m 755 qemu-system-mips64el "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                         
install -m 755 qemu-system-moxie "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-system-or32 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                             
install -m 755 qemu-system-ppc "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                              
install -m 755 qemu-system-ppcemb "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                           
install -m 755 qemu-system-ppc64 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-system-sh4 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                              
install -m 755 qemu-system-sh4eb "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-system-sparc "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-system-sparc64 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                          
install -m 755 qemu-system-s390x "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-system-xtensa "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                           
install -m 755 qemu-system-xtensaeb "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                         
install -m 755 qemu-system-unicore32 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                        
install -m 755 qemu-i386 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                    
install -m 755 qemu-x86_64 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                  
install -m 755 qemu-alpha "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                   
install -m 755 qemu-arm "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                     
install -m 755 qemu-armeb "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                   
install -m 755 qemu-cris "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                    
install -m 755 qemu-m68k "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                    
install -m 755 qemu-microblaze "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                              
install -m 755 qemu-microblazeel "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                            
install -m 755 qemu-mips "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                    
install -m 755 qemu-mipsel "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                  
install -m 755 qemu-mips64 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                  
install -m 755 qemu-mips64el "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                
install -m 755 qemu-mipsn32 "$RPM_BUILD_ROOT/usr/bin"                                                                                                                                                                                                 
install -m 755 qemu-mipsn32el "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-or32 "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-ppc "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-ppc64 "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-ppc64abi32 "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-sh4 "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-sh4eb "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-sparc "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-sparc64 "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-sparc32plus "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-unicore32 "$RPM_BUILD_ROOT/usr/bin"
install -m 755 qemu-s390x "$RPM_BUILD_ROOT/usr/bin"
%clean
rm -rf $RPM_BUILD_ROOT
%post
echo ” ”
%files
%dir /usr/bin/
/usr/bin/qemu-ppc64abi32                 
/usr/bin/qemu-system-x86_64              
/usr/bin/qemu-system-m68k                
/usr/bin/qemu-system-arm                 
/usr/bin/qemu-io                         
/usr/bin/qemu-i386                       
/usr/bin/qemu-system-moxie               
/usr/bin/qemu-system-mipsel              
/usr/bin/qemu-system-sparc64             
/usr/bin/qemu-mipsn32                    
/usr/bin/qemu-or32                       
/usr/bin/qemu-microblazeel               
/usr/bin/qemu-system-alpha               
/usr/bin/qemu-img                        
/usr/bin/qemu-s390x                      
/usr/bin/qemu-nbd                        
/usr/bin/qemu-system-or32                
/usr/bin/qemu-system-ppc                 
/usr/bin/qemu-system-s390x               
/usr/bin/qemu-system-mips64el            
/usr/bin/qemu-mips64el                   
/usr/bin/qemu-sh4                        
/usr/bin/qemu-system-sparc               
/usr/bin/qemu-m68k                       
/usr/bin/qemu-ppc64                      
/usr/bin/qemu-system-xtensa              
/usr/bin/qemu-arm                        
/usr/bin/qemu-mipsel                     
/usr/bin/qemu-sparc                      
/usr/bin/qemu-mips64                     
/usr/bin/qemu-system-cris                
/usr/bin/qemu-system-mips                
/usr/bin/qemu-system-sh4                 
/usr/bin/qemu-sparc64                    
/usr/bin/qemu-sparc32plus                
/usr/bin/qemu-system-i386                
/usr/bin/qemu-system-ppcemb              
/usr/bin/qemu-microblaze                 
/usr/bin/qemu-system-sh4eb               
/usr/bin/qemu-system-lm32                
/usr/bin/qemu-cris                       
/usr/bin/qemu-sh4eb                      
/usr/bin/qemu-armeb                      
/usr/bin/qemu-mips                       
/usr/bin/qemu-system-unicore32           
/usr/bin/qemu-system-xtensaeb            
/usr/bin/qemu-system-microblazeel        
/usr/bin/qemu-alpha                      
/usr/bin/qemu-x86_64                     
/usr/bin/qemu-system-mips64
/usr/bin/qemu-ga
/usr/bin/qemu-unicore32
/usr/bin/qemu-ppc
/usr/bin/qemu-system-microblaze
/usr/bin/qemu-mipsn32el
/usr/bin/qemu-system-ppc64
/usr/libexec/
/usr/libexec/qemu-bridge-helper
/usr/libexec/qemu-kvm
/usr/bin/qemu-ga
/usr/bin/qemu-nbd
/usr/bin/qemu-img
/usr/bin/qemu-io
/usr/share/qemu
/usr/share/qemu/                             
/usr/share/qemu/pxe-e1000.rom                
/usr/share/qemu/openbios-ppc                 
/usr/share/qemu/linuxboot.bin                
/usr/share/qemu/vgabios-qxl.bin              
/usr/share/qemu/efi-rtl8139.rom              
/usr/share/qemu/bamboo.dtb                   
/usr/share/qemu/kvmvapic.bin                 
/usr/share/qemu/efi-eepro100.rom             
/usr/share/qemu/keymaps                      
/usr/share/qemu/keymaps/nl                   
/usr/share/qemu/keymaps/bepo                 
/usr/share/qemu/keymaps/nl-be                
/usr/share/qemu/keymaps/is                   
/usr/share/qemu/keymaps/ar                   
/usr/share/qemu/keymaps/fo                   
/usr/share/qemu/keymaps/fr                   
/usr/share/qemu/keymaps/fi                   
/usr/share/qemu/keymaps/fr-be                
/usr/share/qemu/keymaps/th
/usr/share/qemu/keymaps/pt
/usr/share/qemu/keymaps/de
/usr/share/qemu/keymaps/common
/usr/share/qemu/keymaps/tr
/usr/share/qemu/keymaps/hr
/usr/share/qemu/keymaps/sv
/usr/share/qemu/keymaps/fr-ch
/usr/share/qemu/keymaps/pl
/usr/share/qemu/keymaps/mk
/usr/share/qemu/keymaps/lv
/usr/share/qemu/keymaps/et
/usr/share/qemu/keymaps/en-us
/usr/share/qemu/keymaps/no
/usr/share/qemu/keymaps/es
/usr/share/qemu/keymaps/da
/usr/share/qemu/keymaps/de-ch
/usr/share/qemu/keymaps/ja
/usr/share/qemu/keymaps/en-gb
/usr/share/qemu/keymaps/modifiers
/usr/share/qemu/keymaps/ru
/usr/share/qemu/keymaps/lt
/usr/share/qemu/keymaps/fr-ca
/usr/share/qemu/keymaps/it
/usr/share/qemu/keymaps/pt-br
/usr/share/qemu/keymaps/sl
/usr/share/qemu/keymaps/hu
/usr/share/qemu/vgabios-vmware.bin
/usr/share/qemu/vgabios-cirrus.bin
/usr/share/qemu/petalogix-ml605.dtb
/usr/share/qemu/petalogix-s3adsp1800.dtb
/usr/share/qemu/acpi-dsdt.aml
/usr/share/qemu/q35-acpi-dsdt.aml
/usr/share/qemu/ppc_rom.bin
/usr/share/qemu/s390-ccw.img
/usr/share/qemu/pxe-eepro100.rom
/usr/share/qemu/openbios-sparc64
/usr/share/qemu/pxe-pcnet.rom
/usr/share/qemu/sgabios.bin
/usr/share/qemu/s390-zipl.rom
/usr/share/qemu/efi-ne2k_pci.rom
/usr/share/qemu/vgabios-stdvga.bin
/usr/share/qemu/slof.bin
/usr/share/qemu/spapr-rtas.bin
/usr/share/qemu/pxe-virtio.rom
/usr/share/qemu/efi-e1000.rom
/usr/share/qemu/efi-pcnet.rom
/usr/share/qemu/pxe-ne2k_pci.rom
/usr/share/qemu/palcode-clipper
/usr/share/qemu/pxe-rtl8139.rom
/usr/share/qemu/efi-virtio.rom
/usr/share/qemu/vgabios.bin
/usr/share/qemu/bios.bin
/usr/share/qemu/multiboot.bin
/usr/share/qemu/openbios-sparc32
/usr/share/qemu/qemu-icon.bmp
