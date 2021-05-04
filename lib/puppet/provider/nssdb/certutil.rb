Puppet::Type.type(:nssdb).provide(:certutil) do
  commands :certutil => 'certutil'

	def create
    create_password_file
    create_database

    FileUtils.chown(resource[:owner], resource[:group], Dir.glob(resource[:directory]))
  end

  def destroy
    FileUtils.rmdir(resource[:directory])
  end

  def exists?
    File.exist?(resource[:directory])
  end

  private

  def create_password_file
    File.open(resource[:password_file], 'w') do |file|
      File.write(resource[:password])
    end
  end

  def create_database
    certutil(
      '-N',
      '-d',
      resource[:directory],
      '-f',
      resource[:password_file],
    )
  end

end
