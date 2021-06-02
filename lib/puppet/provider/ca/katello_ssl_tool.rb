require 'fileutils'
require File.expand_path('../../katello_ssl_tool', __FILE__)

Puppet::Type.type(:ca).provide(:katello_ssl_tool, :parent => Puppet::Provider::KatelloSslTool::Cert) do

  protected

  def generate!
    args = [
      '--gen-ca',
      '--dir', resource[:build_dir],
      '--ca-cert-dir', target_path('certs'),
      '--ca-cert', File.basename(pubkey),
    ]

    if existing_pubkey
      FileUtils.mkdir_p(build_path)
      FileUtils.cp(existing_pubkey, build_path(File.basename(pubkey)))
      args << '--rpm-only' if resource[:deploy]
    else
      args.concat([
        '--password', "file:#{resource[:password_file]}",
        '--force',
        '--set-common-name', resource[:common_name],
        '--ca-key', File.basename(privkey),
        *common_args
      ])
    end

    if resource[:deploy]
      args.concat(['--ca-cert-rpm', rpmfile_base_name])
    else
      args << '--no-rpm'
    end

    katello_ssl_tool(*args)
    super
  end

  def existing_pubkey
    if resource[:ca]
      ca_details[:pubkey]
    elsif resource[:custom_pubkey]
      resource[:custom_pubkey]
    end
  end

  def deploy!
    if File.exists?(rpmfile)
      # the rpm is available locally on the file system
      rpm('-Uvh', '--force', rpmfile)
    else
      # we search the rpm in yum repo
      yum("install", "-y", rpmfile_base_name)
    end
  end

  def files_to_deploy
    [pubkey]
  end

  def files_to_generate
    to_generate = [
      "#{resource[:build_dir]}/#{File.basename(pubkey)}",
    ]

    to_generate << "#{resource[:build_dir]}/#{File.basename(privkey)}" unless existing_pubkey
    to_generate
  end

  def self.privkey(name)
    build_path("#{name}.key")
  end

end
