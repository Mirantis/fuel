import os

OS_FAMILY = os.environ.get('OS_FAMILY', "centos")
PUPPET_GEN = os.environ.get('PUPPET_GEN', "2")

DEFAULT_IMAGES = {
    'centos': '/var/lib/libvirt/images/centos63-cobbler-base.qcow2',
    'ubuntu': '/var/lib/libvirt/images/ubuntu-12.04.1-server-amd64-base.qcow2',
}

BASE_IMAGE = os.environ.get('BASE_IMAGE', DEFAULT_IMAGES.get(OS_FAMILY))

PUPPET_VERSIONS = {
    'centos': {
        "2": '2.7.19-1.el6',
        "3": '3.0.1-1.el6',
        },
    'ubuntu': {
        "2": '2.7.19-1puppetlabs2',
        "3": '3.0.1-1puppetlabs1'
    },
}

PUPPET_VERSION = PUPPET_VERSIONS.get(OS_FAMILY).get(PUPPET_GEN)
PUPPET_MASTER_VERSION = PUPPET_VERSIONS.get('centos').get(PUPPET_GEN)

PUPPET_CLIENT_PACKAGES = {
    'centos': {
        "2": 'puppet-2.7.19-1.el6',
        "3": 'puppet-3.0.1-1.el6',
        },
    'ubuntu': {
        "2": 'puppet=2.7.19-1puppetlabs2 puppet-common=2.7.19-1puppetlabs2',
        "3": 'puppet=3.0.1-1puppetlabs1 puppet-common=3.0.1-1puppetlabs1'
    },
}

PUPPET_CLIENT_PACKAGE = PUPPET_CLIENT_PACKAGES.get(OS_FAMILY).get(PUPPET_GEN)

ERROR_PREFIXES = {
    "2": "err: ",
    "3": "Error: ",
}

ERROR_PREFIX = ERROR_PREFIXES.get(PUPPET_GEN)

WARNING_PREFIXES = {
    "2": "warning: ",
    "3": "Warning: ",
}

WARNING_PREFIX = WARNING_PREFIXES.get(PUPPET_GEN)

PUPPET_MASTER_SERVICE = 'thin'

ADMIN_USERNAME = 'admin'
ADMIN_PASSWORD = 'nova'
ADMIN_TENANT_ESSEX = 'openstack'
ADMIN_TENANT_FOLSOM = 'admin'

CIRROS_IMAGE = os.environ.get('CIRROS_IMAGE', 'http://srv08-srt.srt.mirantis.net/cirros-0.3.1-x86_64-disk.img')
CONTROLLERS = int(os.environ.get('CONTROLLERS', 3))
COMPUTES = int(os.environ.get('COMPUTES', 3))
STORAGES = int(os.environ.get('STORAGES', 0))
PROXIES = int(os.environ.get('PROXIES', 0))
QUANTUMS = int(os.environ.get('QUANTUMS', 0))
DEFAULT_RAM_SIZE = int(os.environ.get('DEFAULT_RAM_SIZE', 1536))
COMPUTE_RAM_SIZE = int(os.environ.get('COMPUTE_RAM_SIZE', 2048))

EMPTY_SNAPSHOT = os.environ.get('EMPTY_SNAPSHOT', 'empty')
OPENSTACK_SNAPSHOT = os.environ.get('OPENSTACK_SNAPSHOT', 'openstack')

INTERFACE_ORDER = ('public', 'internal', 'private')

INTERFACES = {
    'public': 'eth0',
    'internal': 'eth1',
    'private': 'eth2',
}

FORWARDING = {
    'public': os.environ.get('PUBLIC_FORWARD', 'nat'),
    'internal': None,
    'private': None,
}

DHCP = {
    'public': True,
    'internal': False,
    'private': False,
}

DEFAULT_POOLS = {
    'centos': {
        'public': '10.108.0.0/16:24',
        'private': '10.108.0.0/16:24',
        'internal': '10.108.0.0/16:24',
        },
    'ubuntu': {
        'public': '10.107.0.0/16:24',
        'private': '10.107.0.0/16:24',
        'internal': '10.107.0.0/16:24',
        },
}

POOLS = {
    'public': os.environ.get('PUBLIC_POOL',
                             DEFAULT_POOLS.get(OS_FAMILY).get('public')).split(':'),
    'private': os.environ.get('PRIVATE_POOL',
                              DEFAULT_POOLS.get(OS_FAMILY).get('private')).split(':'),
    'internal': os.environ.get('INTERNAL_POOL',
                               DEFAULT_POOLS.get(OS_FAMILY).get('internal')).split(':')
}

TEST_REPO = os.environ.get('TEST_REPO', 'false') == 'true'
EXIST_TAR = os.environ.get('EXIST_TAR', None)
CREATE_SNAPSHOTS = os.environ.get('CREATE_SNAPSHOTS', 'true') == 'true'
CLEAN = os.environ.get('CLEAN', 'true') == 'true'
ISO_IMAGE = os.environ.get('ISO_IMAGE', '~/fuel-centos-6.4-x86_64-3.0.1.iso')
USE_ISO = os.environ.get('USE_ISO', 'true') == 'true'
PARENT_PROXY = os.environ.get('PARENT_PROXY', '')
PROFILES_COBBLER_COMMON = {
    'centos': 'centos64_x86_64',
    'ubuntu': 'ubuntu_1204_x86_64'
}

CURRENT_PROFILE = PROFILES_COBBLER_COMMON.get(OS_FAMILY)

ASTUTE_USE = os.environ.get('ASTUTE_USE', 'true') == 'true'
DOMAIN_NAME = os.environ.get('DOMAIN_NAME', '.localdomain')
PUPPET_AGENT_COMMAND = 'puppet agent -tvd --evaltrace 2>&1'
SETUP_TIMEOUT = int(os.environ.get('SETUP_TIMEOUT',600))

QUANTUM_USE_NAMESPACES = os.environ.get('QUANTUM_USE_NAMESPACES', 'true') == 'true'
TENANT_NETWORK_TYPE = os.environ.get('TENANT_NETWORK_TYPE', 'gre')

SLEEP4SV = os.environ.get('SLEEP4SV', 60)




