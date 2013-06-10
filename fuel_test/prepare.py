import subprocess
from time import sleep
from devops.helpers.helpers import ssh
import glanceclient
import keystoneclient.v2_0
#from quantumclient.quantum import client as q_client
from quantumclient.v2_0 import client as q_client
import os
from fuel_test.ci.ci_vm import CiVM
from fuel_test.helpers import load, retry, install_packages, switch_off_ip_tables
from fuel_test.root import root
from fuel_test.settings import ADMIN_USERNAME, ADMIN_PASSWORD, ADMIN_TENANT_ESSEX, ADMIN_TENANT_FOLSOM, OS_FAMILY, CIRROS_IMAGE


class Prepare(object):
    def __init__(self):
        self.controllers = self.ci().nodes().controllers
        if len(self.controllers) == 1:
            self.public_ip = self.controllers[0].get_ip_address_by_network_name('public')
            self.internal_ip = self.controllers[0].get_ip_address_by_network_name('internal')
        else:
            self.public_ip = self.ci().public_virtual_ip()
            print "public", self.public_ip
            self.internal_ip = self.ci().public_virtual_ip()

    def remote(self):
        return ssh(self.public_ip,
                   login='root',
                   password='r00tme').sudo.ssh

    def ci(self):
        if not hasattr(self, '_ci'):
            self._ci = CiVM()
        return self._ci

    def username(self):
        return ADMIN_USERNAME

    def password(self):
        return ADMIN_PASSWORD

    def tenant(self):
            return ADMIN_TENANT_FOLSOM

    def get_auth_url(self):
        return 'http://%s:5000/v2.0/' % self.public_ip

    def make_shared_storage(self):
        self._make_shared_storage(
            self.ci().nodes().controllers[0].name,
            self.ci().nodes().controllers[1:],
            self.ci().internal_network()
        )

    def prepare_tempest_essex_minimal(self):
        self.make_shared_storage()
        self.prepare_tempest_essex()

    def prepare_tempest_folsom_minimal(self):
        self.make_shared_storage()
        self.prepare_tempest_folsom()

    def prepare_tempest_essex(self):
        image_ref, image_ref_alt = self.make_tempest_objects()
        self.tempest_write_config(
            self.tempest_config_essex(image_ref, image_ref_alt))

    def prepare_tempest_folsom(self):
        image_ref, image_ref_alt = self.make_tempest_objects()
        self.tempest_write_config(
            self.tempest_config_folsom(
                image_ref=image_ref,
                image_ref_alt=image_ref_alt,
                path_to_private_key=root('fuel_test', 'config', 'ssh_keys',
                                         'openstack'),
                compute_db_uri='mysql://nova:nova@%s/nova' % self.ci().internal_virtual_ip()
            ))

    def prepare_tempest_grizzly_simple(self):
        image_ref, image_ref_alt, net_id, router_id = self.make_tempest_objects()
        self.tempest_write_config(
            self.tempest_config_grizzly(
                image_ref=image_ref,
                image_ref_alt=image_ref_alt,
                public_network_id=net_id,
                public_router_id=router_id,
                path_to_private_key=root('fuel_test', 'config', 'ssh_keys',
                                         'openstack'),
                compute_db_uri='mysql://nova:nova@%s/nova' % self.internal_ip
            ))

    def tempest_config_grizzly(self, image_ref, image_ref_alt, public_network_id, public_router_id,
                              path_to_private_key,
                              compute_db_uri='mysql://user:pass@localhost/nova'):
        sample = load(
            root('fuel_test', 'config', 'tempest.conf.grizzly.sample'))
        config = sample % {
            'IDENTITY_CATALOG_TYPE': 'identity',
            'IDENTITY_DISABLE_SSL_CHECK': 'true',
            'IDENTITY_USE_SSL': 'false',
            'IDENTITY_URI': 'http://%s:5000/v2.0/' % self.public_ip,
            'IDENTITY_REGION': 'RegionOne',
            'IDENTITY_HOST': self.public_ip,
            'IDENTITY_PORT': '5000',
            'IDENTITY_API_VERSION': 'v2.0',
            'IDENTITY_PATH': 'tokens',
            'IDENTITY_STRATEGY': 'keystone',
            'COMPUTE_ALLOW_TENANT_ISOLATION': 'true',
            'COMPUTE_ALLOW_TENANT_REUSE': 'true',
            'USERNAME': 'tempest1',
            'PASSWORD': 'secret',
            'TENANT_NAME': 'tenant1',
            'ALT_USERNAME': 'tempest2',
            'ALT_PASSWORD': 'secret',
            'ALT_TENANT_NAME': 'tenant2',
            'IMAGE_ID': image_ref,
            'IMAGE_ID_ALT': image_ref_alt,
            'FLAVOR_REF': '1',
            'FLAVOR_REF_ALT': '1', # skip flavor '2' which provides 20Gb ephemerals and lots of RAM...
            'COMPUTE_BUILD_INTERVAL': '10',
            'COMPUTE_BUILD_TIMEOUT': '600',
            'RUN_SSH': 'true',
            'NETWORK_FOR_SSH': 'net04', # todo use private instead of floating?
            'SSH_USER': 'cirros',
            'LIVE_MIGRATION': 'true',
            'USE_BLOCKMIG_FOR_LIVEMIG' : 'true',
            'COMPUTE_CATALOG_TYPE': 'compute',
            'COMPUTE_CREATE_IMAGE_ENABLED': 'true',
            'COMPUTE_RESIZE_AVAILABLE': 'false', # not supported with QEMU...
            'COMPUTE_CHANGE_PASSWORD_AVAILABLE': 'false',
            'COMPUTE_LOG_LEVEL': 'ERROR',
            'COMPUTE_WHITEBOX_ENABLED': 'true',
            'COMPUTE_SOURCE_DIR': '/opt/stack/nova',
            'COMPUTE_CONFIG_PATH': '/etc/nova/nova.conf',
            'COMPUTE_BIN_DIR': '/usr/local/bin',
            'COMPUTE_PATH_TO_PRIVATE_KEY': path_to_private_key,
            'COMPUTE_DB_URI': compute_db_uri,
            'IMAGE_CATALOG_TYPE': 'image',
            'IMAGE_API_VERSION': '1',
            'IMAGE_HOST': self.public_ip,
            'IMAGE_PORT': '9292',
            'IMAGE_USERNAME': 'tempest1',
            'IMAGE_PASSWORD': 'secret',
            'IMAGE_TENANT_NAME': 'tenant1',
            'ADMIN_USER_NAME': ADMIN_USERNAME,
            'ADMIN_PASSWORD': ADMIN_PASSWORD,
            'ADMIN_TENANT_NAME': ADMIN_TENANT_FOLSOM,
            'IDENTITY_ADMIN_USERNAME': ADMIN_USERNAME,
            'IDENTITY_ADMIN_PASSWORD': ADMIN_PASSWORD,
            'IDENTITY_ADMIN_TENANT_NAME': ADMIN_TENANT_FOLSOM,
            'COMPUTE_ADMIN_USERNAME': ADMIN_USERNAME,
            'COMPUTE_ADMIN_PASSWORD': ADMIN_PASSWORD,
            'COMPUTE_ADMIN_TENANT_NAME': ADMIN_TENANT_FOLSOM,
            'IDENTITY_ADMIN_USERNAME': ADMIN_USERNAME,
            'IDENTITY_ADMIN_PASSWORD': ADMIN_PASSWORD,
            'IDENTITY_ADMIN_TENANT_NAME': ADMIN_TENANT_FOLSOM,
            'VOLUME_CATALOG_TYPE': 'volume',
            'VOLUME_BUILD_INTERVAL': '15',
            'VOLUME_BUILD_TIMEOUT': '400',
            'NETWORK_CATALOG_TYPE': 'network',
            'NETWORK_API_VERSION': 'v2.0',
            'QUANTUM': 'true',
            'TENANT_NETS_REACHABLE': 'false',
            'TENANT_NETWORK_CIDR': '192.168.112.0/24', # choose do not overlap with 'net04'
            'TENANT_NETWORK_MASK_BITS': '28', # 29 is too less to test quantum quotas (at least 50 ips needed)
            'PUBLIC_NETWORK_ID': public_network_id,
            'PUBLIC_ROUTER_ID': public_router_id,
        }
        return config

    def tempest_config_folsom(self, image_ref, image_ref_alt,
                              path_to_private_key,
                              compute_db_uri='mysql://user:pass@localhost/nova'):
        sample = load(
            root('fuel_test', 'config', 'tempest.conf.folsom.sample'))
        config = sample % {
            'IDENTITY_USE_SSL': 'false',
            'IDENTITY_HOST': self.public_ip,
            'IDENTITY_PORT': '5000',
            'IDENTITY_API_VERSION': 'v2.0',
            'IDENTITY_PATH': 'tokens',
            'IDENTITY_STRATEGY': 'keystone',
            'COMPUTE_ALLOW_TENANT_ISOLATION': 'true',
            'COMPUTE_ALLOW_TENANT_REUSE': 'true',
            'USERNAME': 'tempest1',
            'PASSWORD': 'secret',
            'TENANT_NAME': 'tenant1',
            'ALT_USERNAME': 'tempest2',
            'ALT_PASSWORD': 'secret',
            'ALT_TENANT_NAME': 'tenant2',
            'IMAGE_ID': image_ref,
            'IMAGE_ID_ALT': image_ref_alt,
            'FLAVOR_REF': '1',
            'FLAVOR_REF_ALT': '2',
            'COMPUTE_BUILD_INTERVAL': '10',
            'COMPUTE_BUILD_TIMEOUT': '600',
            'RUN_SSH': 'false',
            'NETWORK_FOR_SSH': 'novanetwork',
            'COMPUTE_CATALOG_TYPE': 'compute',
            'COMPUTE_CREATE_IMAGE_ENABLED': 'true',
            'COMPUTE_RESIZE_AVAILABLE': 'true',
            'COMPUTE_CHANGE_PASSWORD_AVAILABLE': 'false',
            'COMPUTE_LOG_LEVEL': 'DEBUG',
            'COMPUTE_WHITEBOX_ENABLED': 'true',
            'COMPUTE_SOURCE_DIR': '/opt/stack/nova',
            'COMPUTE_CONFIG_PATH': '/etc/nova/nova.conf',
            'COMPUTE_BIN_DIR': '/usr/local/bin',
            'COMPUTE_PATH_TO_PRIVATE_KEY': path_to_private_key,
            'COMPUTE_DB_URI': compute_db_uri,
            'IMAGE_CATALOG_TYPE': 'image',
            'IMAGE_API_VERSION': '1',
            'IMAGE_HOST': self.public_ip,
            'IMAGE_PORT': '9292',
            'IMAGE_USERNAME': 'tempest1',
            'IMAGE_PASSWORD': 'secret',
            'IMAGE_TENANT_NAME': 'tenant1',
            'COMPUTE_ADMIN_USERNAME': ADMIN_USERNAME,
            'COMPUTE_ADMIN_PASSWORD': ADMIN_PASSWORD,
            'COMPUTE_ADMIN_TENANT_NAME': ADMIN_TENANT_FOLSOM,
            'IDENTITY_ADMIN_USERNAME': ADMIN_USERNAME,
            'IDENTITY_ADMIN_PASSWORD': ADMIN_PASSWORD,
            'IDENTITY_ADMIN_TENANT_NAME': ADMIN_TENANT_FOLSOM,
            'VOLUME_CATALOG_TYPE': 'volume',
            'VOLUME_BUILD_INTERVAL': '10',
            'VOLUME_BUILD_TIMEOUT': '300',
            'NETWORK_CATALOG_TYPE': 'network',
            'NETWORK_API_VERSION': 'v2.0',
        }
        return config

    def tempest_config_essex(self, image_ref, image_ref_alt):
        sample = load(
            root('fuel_test', 'config', 'tempest.conf.essex.sample'))
        config = sample % {
            'HOST': self.public_ip,
            'USERNAME': 'tempest1',
            'PASSWORD': 'secret',
            'TENANT_NAME': 'tenant1',
            'ALT_USERNAME': 'tempest2',
            'ALT_PASSWORD': 'secret',
            'ALT_TENANT_NAME': 'tenant2',
            'IMAGE_ID': image_ref,
            'IMAGE_ID_ALT': image_ref_alt,
            'ADMIN_USERNAME': ADMIN_USERNAME,
            'ADMIN_PASSWORD': ADMIN_PASSWORD,
            'ADMIN_TENANT_NAME': ADMIN_TENANT_ESSEX,
        }
        return config

    def tempest_write_config(self, config):
        with open(root('..', 'tempest.conf'), 'w') as f:
            f.write(config)

    def _get_images(self, glance, name):
        """ Retrieve all images with a certain name """
        images = [x for x in glance.images.list() if x.name == name]
        return images

    def _get_tenants(self, keystone, name1, name2):
        """ Retrieve all tenants with a certain names """
        tenants = [x for x in keystone.tenants.list() if x.name == name1 or x.name == name2]
        return tenants
       
    def _get_users(self, keystone, name1, name2):
        """ Retrieve all users with a certain names """
        users = [x for x in keystone.users.list() if x.name == name1 or x.name == name2]
        return users

    def make_tempest_objects(self, ):
        keystone = self._get_identity_client()
        tenants = self._get_tenants(keystone, 'tenant1', 'tenant2')
        if len(tenants) > 1:
            tenant1 = tenants[0].id 
            tenant2 = tenants[1].id
        else:
            tenant1 = retry(10, keystone.tenants.create, tenant_name='tenant1')
            tenant2 = retry(10, keystone.tenants.create, tenant_name='tenant2')

        users = self._get_users(keystone, 'tempest1', 'tempest2')
        if len(users) == 0:
            retry(10, keystone.users.create, name='tempest1', password='secret',
              email='tempest1@example.com', tenant_id=tenant1.id)
            retry(10, keystone.users.create, name='tempest2', password='secret',
              email='tempest2@example.com', tenant_id=tenant2.id)
        
        image_ref, image_ref_alt = self.tempest_add_images()
        net_id, router_id = self.tempest_get_netid_routerid()
        return image_ref, image_ref_alt, net_id, router_id

    def _get_identity_client(self):
        keystone = retry(10, keystoneclient.v2_0.client.Client,
                         username=self.username(), password=self.password(),
                         tenant_name=self.tenant(),
                         auth_url=self.get_auth_url())
        return keystone

    def _get_image_client(self):
        keystone = self._get_identity_client()
        endpoint = keystone.service_catalog.url_for(service_type='image',
                                                    endpoint_type='publicURL')
        return glanceclient.Client('1', endpoint=endpoint,
                                   token=keystone.auth_token)

    def _get_networking_client(self):
        quantum = retry(10, q_client.Client,
                         username=self.username(), password=self.password(),
                         tenant_name=self.tenant(),
                         auth_url=self.get_auth_url())
        return quantum

    def upload(self, glance, name, path):
        image = glance.images.create(
            name=name,
            is_public=True,
            container_format='bare',
            disk_format='qcow2')
        image.update(data=open(path, 'rb'))
        return image.id

    def tempest_add_images(self):
        if not os.path.isfile('cirros-0.3.0-x86_64-disk.img'):
            subprocess.check_call(['wget', CIRROS_IMAGE])
        glance = self._get_image_client()
        images = self._get_images(glance, 'cirros_0.3.0')
        if len(images) > 1:
            return images[0].id, images[1].id
        else:
            return self.upload(glance, 'cirros_0.3.0',
                           'cirros-0.3.0-x86_64-disk.img'), \
               self.upload(glance, 'cirros_0.3.0',
                           'cirros-0.3.0-x86_64-disk.img')

    def tempest_get_netid_routerid(self):
        networking = self._get_networking_client()
        params = {'router:external': True}
        # Assume only 1 ext net and 1 ext router exists 
        network = networking.list_networks(**params)['networks'][0]['id']
        router = networking.list_routers()['routers'][0]['id']
        return network, router

    def tempest_share_glance_images(self, network):
        if OS_FAMILY == "centos":
            self.remote().check_stderr('chkconfig rpcbind on')
            self.remote().check_stderr('/etc/init.d/rpcbind restart')
            self.remote().check_stderr(
                'echo "/var/lib/glance/images %s(rw,no_root_squash)" >> /etc/exports' % network)
            self.remote().check_stderr('/etc/init.d/nfs restart')
        else:
            install_packages(self.remote(),
                             'nfs-kernel-server nfs-common portmap')
            self.remote().check_stderr(
                'echo "/var/lib/glance/images %s(rw,no_root_squash)" >> /etc/exports' % network)
            self.remote().check_stderr('/etc/init.d/nfs-kernel-server restart')

    def tempest_mount_glance_images(self, remote, host):
        if OS_FAMILY == "centos":
            remote.check_stderr('chkconfig rpcbind on')
            remote.check_stderr('/etc/init.d/rpcbind restart')
            remote.check_stderr(
                'mount %s:/var/lib/glance/images /var/lib/glance/images' % host)
        else:
            install_packages(remote, 'nfs-common portmap')
            remote.check_stderr(
                'mount %s:/var/lib/glance/images /var/lib/glance/images' % host)

    def _make_shared_storage(self, nfs_server, nfs_clients, access_network):
        self.tempest_share_glance_images(access_network)
        switch_off_ip_tables(self.remote())
        self.remote().check_stderr('/etc/init.d/iptables stop')
        sleep(15)
        for client in nfs_clients:
            remote = client.remote(
                'internal', login='root',
                password='r00tme').sudo.ssh
            self.tempest_mount_glance_images(remote, nfs_server)
        sleep(20)


if __name__ == '__main__':
    Prepare().prepare_tempest_grizzly_simple()
