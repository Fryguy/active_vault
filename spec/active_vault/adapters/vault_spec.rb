RSpec.describe ActiveVault::Adapters::Vault, :vcr do
  let(:address)    { VAULT_ADDRESS }
  let(:token)      { VAULT_TOKEN }
  let(:namespace)  { VAULT_NAMESPACE }
  let(:connection) { described_class.new("address" => address, "token" => token) }

  describe "#read" do
    it "when the value exists" do
      expect(connection.read(namespace, "read_test")).to eq(:value => "read_test_value")
    end

    it "when the value does not exist" do
      expect(connection.read(namespace, "foo")).to be_nil
    end
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
