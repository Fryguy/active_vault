require "tempfile"
require "yaml"

RSpec.describe ActiveVault::Base do
  after do
    described_class.instance_variable_set(:@env, nil)
    described_class.instance_variable_set(:@config_file, nil)
    described_class.instance_variable_set(:@config, nil)
    described_class.instance_variable_set(:@connection, nil)
  end

  def stub_rails
    stub_const("Rails",
      double("Rails",
        :env  => "production",
        :root => Pathname.new("/tmp/rails")
      )
    )
  end

  def stub_config_file
    file = Tempfile.new(["vault", ".yml"])
    File.write(file.path, {"production" => {"adapter" => "vault", "address" => "prod_addr"}}.to_yaml)
    file.path
  end

  describe ".env" do
    it "uses a configured value directly" do
      described_class.env = "foo"

      expect(described_class.env).to eq "foo"
    end

    it "uses Rails.env when Rails is present" do
      stub_rails

      expect(described_class.env).to eq "production"
    end

    it "prefers a configured value over Rails env" do
      stub_rails
      described_class.env = "foo"

      expect(described_class.env).to eq "foo"
    end

    it "defaults to 'development'" do
      expect(described_class.env).to eq "development"
    end
  end

  describe ".config_file" do
    it "uses a configured value directly" do
      described_class.config_file = Pathname.new("/tmp/foo.yml")

      expect(described_class.config_file).to eq Pathname.new("/tmp/foo.yml")
    end

    it "uses a default Rails path when Rails is present" do
      stub_rails

      expect(described_class.config_file).to eq Pathname.new("/tmp/rails/config/vault.yml")
    end

    it "prefers a configured value over Rails env" do
      stub_rails
      described_class.config_file = Pathname.new("/tmp/foo.yml")

      expect(described_class.config_file).to eq Pathname.new("/tmp/foo.yml")
    end

    it "defaults to pwd" do
      expect(described_class.config_file).to eq Pathname.pwd.join("config/vault.yml")
    end
  end

  describe ".config" do
    it "uses a configured value directly" do
      described_class.config = {"adapter" => "vault"}

      expect(described_class.config).to eq("adapter" => "vault")
    end

    it "reads from the config file for the current env" do
      stub_rails
      described_class.config_file = stub_config_file

      expect(described_class.config).to eq("adapter" => "vault", "address" => "prod_addr")
    end

    it "prefers a configured value over a config file" do
      described_class.config = {"adapter" => "vault"}
      stub_rails
      described_class.config_file = stub_config_file

      expect(described_class.config).to eq("adapter" => "vault")
    end
  end

  describe ".raw_connect" do
    it "returns an adapter instance" do
      connection = described_class.raw_connect("adapter" => "vault", "address" => "http://localhost:8200", "token" => "abcd")
      expect(connection).to be_a ActiveVault::Adapters::Vault
    end
  end

  describe ".connection" do
    before do
      described_class.config = {"adapter" => "vault", "address" => "http://localhost:8200", "token" => "abcd"}
    end

    it "returns an adapter instance" do
      connection = described_class.connection
      expect(connection).to be_a ActiveVault::Adapters::Vault
    end

    it "returns the same adapter instance on subsequent calls" do
      connection1 = described_class.connection
      expect(connection1).to be_a ActiveVault::Adapters::Vault

      connection2 = described_class.connection
      expect(connection2).to be_a ActiveVault::Adapters::Vault

      expect(connection1).to be_equal connection2
    end
  end
end
