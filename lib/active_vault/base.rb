require "active_support/core_ext/string/inflections"
require "pathname"
require "yaml"

module ActiveVault
  module Base
    def self.env
      return @env if @env
      return Rails.env if defined?(Rails)
      @env = "development"
    end

    class << self
      attr_writer :env
    end

    def self.config_file
      return @config_file if @config_file
      return Rails.root.join("config/vault.yml") if defined?(Rails)
      @config_file = Pathname.pwd.join("config/vault.yml")
    end

    def self.config_file=(file)
      file = Pathname.new(file) unless file.is_a?(Pathname)
      @config_file = file
    end

    def self.config
      return @config if @config
      YAML.load_file(config_file)[env]
    end

    class << self
      attr_writer :config
    end

    def self.connection
      @connection ||= raw_connect(config)
    end

    def self.raw_connect(options)
      adapter = "ActiveVault::Adapters::#{options["adapter"].to_s.camelize}".safe_constantize
      unless adapter < ActiveVault::Adapters::Base
        raise ArgumentError, "adapter #{options["adapter"].inspect} is invalid"
      end

      adapter.connect(options.except("adapter"))
    end
  end
end
