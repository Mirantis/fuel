# Custom repos
class openstack::custom_repos (
  $openstack_repo_name = undef,
  $openstack_repo = undef,
) {
    notify {"Creating custom Repo: $openstack_repo_name ":}
    if ($openstack_repo_name) {
      yumrepo { $openstack_repo_name:
        descr      => 'OpenStack packages',
        baseurl    => $openstack_repo,
        gpgcheck   => '0',
        priority   => '1'
      }
    }
}
