require_relative "base"
require "active_support/core_ext/hash/keys"

module ActiveVault::Adapters
  class Vault < Base
    def self.available?
      require "vault"
      true
    rescue LoadError, StandardError
      false
    end

    attr_reader :raw_connection

    def initialize(options = {})
      raise ArgumentError, "vault ruby gem must be installed" unless self.class.available?

      options = options.symbolize_keys
      raise ArgumentError, "address must be specified" unless options[:address]
      raise ArgumentError, "token must be specified" unless options[:token]

      @raw_connection = ::Vault::Client.new(options)
    end

    def valid?
      !!health_status
    rescue
      false
    end

    def version
      health_status.version
    end

    def read(namespace, name)
      wrapping_exceptions do
        raw_connection.kv(namespace).read(name)&.data
      end
    end

    def write(namespace, name, contents)
      wrapping_exceptions do
        raw_connection.kv(namespace).write(name, contents)
      end
    end

    def delete(namespace, name)
      wrapping_exceptions do
        raw_connection.kv(namespace).delete(name)
      end
    end

    def list(namespace)
      wrapping_exceptions do
        raw_connection.kv(namespace).list
      end
    end

    private def wrapping_exceptions
      yield
    rescue ::Vault::HTTPConnectionError => err
      raise ActiveVault::ConnectionError, err.to_s
    # rescue => err
    #   raise ActiveVault::Error, err.to_s
    end

    private def health_status
      wrapping_exceptions do
        raw_connection.sys.health_status
      end
    end
  end
end
