# Sets up nssdb
class certs::ssltools::nssdb (
  $nss_db_dir = $certs::nss_db_dir,
  $group = 'qpidd',
)  {
  $nss_db_password_file = "${nss_db_dir}/nss_db_password-file"

  ensure_packages(['openssl', 'nss-tools'])

  $password = extlib::cache_data('foreman_cache_data', 'nss_db_password-file', extlib::random_password(32))

  file { $nss_db_dir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => '0750',
  }

  nssdb { $nss_db_dir:
    password      => $password,
    password_file => $nss_db_password_file,
    owner         => 'root',
    group         => $group,
  }
}
