Puppet::Type.newtype(:nssdb) do
  desc 'adds a certificate to a pkcs12 truststore'

  ensurable

  newparam(:directory, :namevar => true) do
    desc "The directory that represents the NSS database"
    isrequired
  end

  newparam(:password) do
    desc "Password to use when managing the NSS database"
    isrequired
  end

  newparam(:password_file) do
    desc "File to store the password in when managing the NSS database"
    isrequired
  end

  newparam(:owner) do
    desc "Owner of the NSS database directory and files"
  end

  newparam(:group) do
    desc "Group associted to the NSS database directory and files"
  end

  autorequire(:file) do
    [self[:password_file], self[:directory]]
  end

  autorequire(:package) do
    ['openssl', 'nss-tools']
  end
end
