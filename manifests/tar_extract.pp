# Definition: certs::tar_extract
#
# This class extracts a tarball
#
# Parameters:
# - The $path of the tarball to extract
#
# Actions:
# - Extracts a tarball
#
class certs::tar_extract (
  Stdlib::Absolutepath $path,
) {
  validate_file_exists($path)

  exec { "extract ${path}":
    cwd     => '/root',
    path    => ['/usr/bin', '/bin'],
    command => "tar -xaf ${path}",
  }
}
