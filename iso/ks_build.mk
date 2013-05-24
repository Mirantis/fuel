define ks_build_cfg
install
text
reboot --eject
lang en_US.UTF-8
keyboard us
rootpw r00tme
timezone --utc Etc/UTC
zerombr
firewall --disabled
selinux --disabled
clearpart --all --initlabel

#Repository configuration
%include $(BUILD_DIR)/iso/ksrepos.cfg

%packages --nobase --excludedocs
wget
curl
crontabs
cronie
puppet-2.7.19-1
puppet-server-2.7.19-1
-puppet-3.2.1
-puppet-3.2.1-1
puppetdb
man
yum
openssh-clients
ntp
vim-enhanced
authconfig
system-config-firewall-base
policycoreutils
selinux-policy-targeted

# Ruby
rubygem-httpclient
rubygem-ipaddress
rubygem-json_pure
rubygem-ohai
rubygem-rethtool

qemu-guest-agent
nailgun-agent
nailgun-mcagents
nailgun-net-check
send2syslog

#Packages needed for mirror
%include $(TOP_DIR)/requirements-rpm.txt
%end 
endef
