namespace :spec do
  namespace :vault do
    desc "Prepare a local Vault instance with spec data."
    task :setup do
      require_relative "../../spec/support/vault_params"
      require_relative "../../spec/support/fixture_data"

      require "vault"
      client = ::Vault::Client.new(:address => VAULT_ADDRESS, :token => VAULT_TOKEN)
      client.sys.mount(VAULT_NAMESPACE, "kv", VAULT_NAMESPACE, :options => {:version => 2})

      fixture_data.each do |i|
        client.kv(i["namespace"]).write(i["key"], i["value"])
      end
    end

    desc "Remove spec data from a local Vault instance."
    task :teardown do
      require_relative "../../spec/support/vault_params"

      client = ::Vault::Client.new(:address => VAULT_ADDRESS, :token => VAULT_TOKEN)
      client.sys.unmount(VAULT_NAMESPACE)
    end
  end
end
