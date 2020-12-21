# Certs Configuration
class certs::config (
  $pki_dir = $certs::pki_dir,
  $group   = $certs::group,
) {

  file { $pki_dir:
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  }

  ensure_resource('file', '/etc/foreman', {
    ensure => directory,
  })

  ensure_resource('file', $certs::foreman_pki_dir, {
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  })

  file { "${pki_dir}/certs":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  }

  file { "${pki_dir}/private":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0750',
  }

}
