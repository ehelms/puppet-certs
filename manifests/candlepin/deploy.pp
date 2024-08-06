# Constains certs deployment specification for Candlepin
class certs::candlepin::deploy (
  Stdlib::Absolutepath $source_dir,
  Stdlib::Absolutepath $ca_cert,
  Stdlib::Absolutepath $ca_key,
  Stdlib::Absolutepath $ca_key_password_file,
  Stdlib::Absolutepath $certificate,
  Stdlib::Absolutepath $private_key,
  Stdlib::Absolutepath $client_cert,
  String $owner = 'root',
  String $group = 'tomcat',
  String $keystore_password_file = 'keystore_password-file',
  String $truststore_password_file = 'truststore_password-file',
) {

  $certs_dir              = '/etc/candlepin/certs'
  $keystore               = "${certs_dir}/keystore"
  $truststore             = "${certs_dir}/truststore"

  $artemis_alias = 'artemis-client'
  $artemis_client_dn = $certs::foreman::client_dn
  $tomcat_cert_name = "${hostname}-tomcat"

  $keystore_password = extlib::cache_data('foreman_cache_data', $keystore_password_file, extlib::random_password(32))
  $truststore_password = extlib::cache_data('foreman_cache_data', $truststore_password_file, extlib::random_password(32))
  $keystore_password_path = "${certs_dir}/${keystore_password_file}"
  $truststore_password_path = "${certs_dir}/${truststore_password_file}"
  $alias = 'candlepin-ca'

  private_key { "${certs_dir}/candlepin-ca.key":
    ensure        => present,
    source        => $ca_key,
    decrypt       => true,
    password_file => $ca_key_password_file,
    owner         => $owner,
    group         => $group,
    mode          => '0440',
  }

  file { "${certs_dir}/candlepin-ca.crt":
    ensure => file,
    source => $ca_cert,
    owner  => $owner,
    group  => $group,
    mode   => '0440',
  }

  file { $keystore_password_path:
    ensure    => file,
    content   => $keystore_password,
    owner     => 'root',
    group     => $group,
    mode      => '0440',
    show_diff => false,
  }

  keystore { $keystore:
    ensure        => present,
    password_file => $keystore_password_path,
    owner         => 'root',
    group         => $group,
    mode          => '0640',
  }

  keystore_certificate { "${keystore}:tomcat":
    ensure        => present,
    password_file => $keystore_password_path,
    certificate   => $certificate,
    private_key   => $private_key,
    ca            => $ca_cert,
  }

  file { $truststore_password_path:
    ensure    => file,
    content   => $truststore_password,
    owner     => 'root',
    group     => $group,
    mode      => '0440',
    show_diff => false,
  }

  truststore { $truststore:
    ensure        => present,
    password_file => $truststore_password_path,
    owner         => 'root',
    group         => $group,
    mode          => '0640',
  }

  truststore_certificate { "${truststore}:${alias}":
    ensure        => present,
    password_file => $truststore_password_path,
    certificate   => $ca_cert,
  }

  truststore_certificate { "${truststore}:${artemis_alias}":
    ensure        => present,
    password_file => $truststore_password_path,
    certificate   => $client_cert,
  }
}
