require 'spec_helper_acceptance'

describe 'certs::domain' do
  context 'with default parameters' do
    let(:pp) do
      'include certs::domain'
    end

    it 'should force regeneration' do
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}.update ; fi"
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate("/etc/foreman/pki/#{fact('fqdn')}/#{fact('fqdn')}.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key("/etc/foreman/pki/#{fact('fqdn')}/#{fact('fqdn')}.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/etc/foreman/pki/#{fact('fqdn')}/#{fact('fqdn')}.crt") }
    end

    describe package(fact('fqdn')) do
      it { should be_installed }
    end
  end

  context 'with server cert' do
    before(:context) do
      ['crt', 'key'].each do |ext|
        source_path = "fixtures/example.partial.solutions.#{ext}"
        dest_path = "/server.#{ext}"
        scp_to(hosts, source_path, dest_path)
      end

      # Force regen
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}.update ; fi"
    end

    let(:pp) do
      <<-EOS
      class { '::certs::domain':
        server_cert => '/server.crt',
        server_key  => '/server.key',
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate("/etc/foreman/pki/#{fact('fqdn')}/#{fact('fqdn')}.crt") do
      it { should be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', 'CN = Fake LE Intermediate X1'
      include_examples 'certificate subject', 'CN = example.partial.solutions'
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key("/etc/foreman/pki/#{fact('fqdn')}/#{fact('fqdn')}.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/etc/foreman/pki/#{fact('fqdn')}/#{fact('fqdn')}.crt") }
    end

    describe package(fact('fqdn')) do
      it { should be_installed }
    end
  end
end
