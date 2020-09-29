require_relative "../../spec/support/vault_params"

namespace :spec do
  namespace :vault do
    desc "Prepare a local Vault instance with spec data."
    task :setup do
      require "vault"
      client = ::Vault::Client.new(:address => VAULT_ADDRESS, :token => VAULT_TOKEN)
      client.sys.mount(VAULT_NAMESPACE, "kv", VAULT_NAMESPACE)

      require "yaml"
      YAML.load_file(File.expand_path("../../spec/support/fixture_data.yml", __dir__)).each do |i|
        client.kv(i["namespace"]).write(i["key"], i["value"])
      end
    end

    desc "Remove spec data from a local Vault instance."
    task :teardown do
      client = ::Vault::Client.new(:address => VAULT_ADDRESS, :token => VAULT_TOKEN)
      client.sys.unmount(VAULT_NAMESPACE)
    end
  end
end
