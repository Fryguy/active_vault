RSpec.describe ActiveVault::Adapters::Vault, :vcr do
  let(:address)    { VAULT_ADDRESS }
  let(:token)      { VAULT_TOKEN }
  let(:namespace)  { VAULT_NAMESPACE }
  let(:connection) { described_class.new("address" => address, "token" => token) }

  it "#raw_connection", :vcr => false do
    expect(connection.raw_connection).to be_a ::Vault::Client
  end

  describe "#read" do
    it "an existing value" do
      expect(connection.read(namespace, "read_test")).to eq(:value => "read_test_value")
    end

    it "a nonexistent value" do
      expect(connection.read(namespace, "foo")).to be_nil
    end
  end

  describe "#write" do
    it "a new value" do
      key   = "write_test_new"
      value = {:value => "write_test_new_value"}
      expect(connection.read(namespace, key)).to be_nil

      connection.write(namespace, key, value)
      written_value = connection.read(namespace, key)
      connection.destroy(namespace, key) # Restore

      expect(written_value).to eq value
    end

    it "an existing value" do
      key   = "write_test"
      value = {:value => "new_write_test_value"}
      original_value = connection.read(namespace, key)
      expect(original_value).to eq(:value => "write_test_value")

      connection.write(namespace, key, value)
      written_value = connection.read(namespace, key)
      connection.write(namespace, key, original_value) # Restore

      expect(written_value).to eq value
    end
  end

  describe "#delete" do
    it "an existing value" do
      key   = "delete_test"
      value = {:value => "delete_test_value"}
      original_value = connection.read(namespace, key)
      expect(original_value).to eq(value)

      expect(connection.delete(namespace, key)).to eq true
      exists = connection.list(namespace).include?(key)
      connection.write(namespace, key, original_value) # Restore

      expect(exists).to eq true
    end

    it "a nonexistent value" do
      expect(connection.delete(namespace, "foo")).to eq true
    end
  end

  describe "#destroy" do
    it "an existing value" do
      key   = "destroy_test"
      value = {:value => "destroy_test_value"}
      original_value = connection.read(namespace, key)
      expect(original_value).to eq(value)

      expect(connection.destroy(namespace, key)).to eq true
      exists = connection.list(namespace).include?(key)
      connection.write(namespace, key, original_value) # Restore

      expect(exists).to eq false
    end

    it "a nonexistent value" do
      expect(connection.destroy(namespace, "foo")).to eq true
    end
  end

  it "#list" do
    keys = fixture_data.map { |c| c["key"] }
    expect(connection.list(namespace)).to match_array(keys)
  end

  it "#version" do
    expect(connection.version).to eq("1.4.2")
  end

  describe "#valid?" do
    it "when valid" do
      expect(connection).to be_valid
    end

    it "when not valid", :vcr => false do
      expect(connection.send(:raw_connection)).to receive_message_chain(:sys, :health_status).and_raise(::Vault::HTTPConnectionError)
      expect(connection).to_not be_valid
    end
  end
end
