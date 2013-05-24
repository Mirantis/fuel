define yum_ks_repos
repo --name=base --baseurl=$(MIRROR_CENTOS)/ --cost=10
#repo --name=base --baseurl=$(MIRROR_CENTOS)/$(CENTOS_RELEASE)/os/$(CENTOS_ARCH) --cost=10
#repo --name=updates --baseurl=$(MIRROR_CENTOS)/$(CENTOS_RELEASE)/updates/$(CENTOS_ARCH) --cost=10
repo --name=updates --baseurl=$(MIRROR_CENTOS_UPDATES)/ --cost=10
#repo --name=extras --baseurl=$(MIRROR_CENTOS)/$(CENTOS_RELEASE)/extras/$(CENTOS_ARCH) --cost=10
#repo --name=centosplus --baseurl=$(MIRROR_CENTOS)/$(CENTOS_RELEASE)/centosplus/$(CENTOS_ARCH) --cost=10
#repo --name=contrib --baseurl=$(MIRROR_CENTOS)/$(CENTOS_RELEASE)/contrib/$(CENTOS_ARCH) --cost=10
#repo --name=epel --baseurl=http://mirror.yandex.ru/epel/$(CENTOS_MAJOR)/$(CENTOS_ARCH) --cost=20
repo --name=openstack-epel-fuel --mirrorlist=http://download.mirantis.com/epel-fuel-folsom-2.1/mirror.internal-stage.list --cost=1
#repo --name=openstack-epel-fuel --mirrorlist=http://download.mirantis.com/epel-fuel-folsom-2.1/mirror.internal.list --cost=1
#repo --name=openstack-epel-fuel-grizzly --baseurl=http://osci-koji.srt.mirantis.net/mash/epel-fuel-grizzly/x86_64/ --cost=1
repo --name=puppetlabs --baseurl=http://yum.puppetlabs.com/el/6/products/x86_64/ --cost=5
repo --name=puppetosci --baseurl=http://osci-koji.srt.mirantis.net/mash/puppet27/x86_64/ --cost=5
repo --name=puppetlabs-deps --baseurl=http://yum.puppetlabs.com/el/6/dependencies/x86_64/ --cost=200
#repo --name=devel_puppetlabs --baseurl=http://yum.puppetlabs.com/el/6/devel/x86_64/ --cost=5
#repo --name=rpmforge --baseurl=http://apt.sw.be/redhat/el6/en/x86_64/rpmforge --cost=5
#repo --name=rpmforge-extras --baseurl=http://apt.sw.be/redhat/el6/en/x86_64/extras --cost=5
#repo --name=proprietary --baseurl=$(MIRROR_CENTOS)/6.3/os/x86_64 --cost=5
endef

