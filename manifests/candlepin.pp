# Constains certs specific configurations for candlepin
class certs::candlepin (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $ca_cert = $certs::candlepin_ca_cert,
  Stdlib::Absolutepath $ca_key = $certs::candlepin_ca_key,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Stdlib::Absolutepath $keystore = $certs::candlepin_keystore,
  String $keystore_password_file = 'keystore_password-file',
  Stdlib::Absolutepath $truststore = $certs::candlepin_truststore,
  String $truststore_password_file = 'truststore_password-file',
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = $certs::org,
  String $org_unit = $certs::org_unit,
  String $expiration = $certs::expiration,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  String $user = 'root',
  String $group = 'tomcat',
  String $client_keypair_group = 'tomcat',
) inherits certs {
  include certs::foreman

  $tomcat_cert_name = "${hostname}-tomcat"

  cert { $tomcat_cert_name:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => $org,
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    class { 'certs::candlepin::deploy':
      source_dir        => $certs::ssl_build_dir,
      ca_key            => "${certs::ssl_build_dir}/${certs::default_ca_name}.key",
      ca_cert            => "${certs::ssl_build_dir}/${certs::default_ca_name}.crt",
      ca_key_password_file => $ca_key_password_file,
      owner             => 'root',
      group             => $group,
      certificate       => "${certs::ssl_build_dir}/${hostname}/${tomcat_cert_name}.crt",
      private_key       => "${certs::ssl_build_dir}/${hostname}/${tomcat_cert_name}.key",
      client_cert       => $certs::foreman::client_cert,
      require           => [Cert[$tomcat_cert_name], Ca[$certs::default_ca_name]]
    }
  }
}
