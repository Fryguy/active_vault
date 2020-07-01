module ActiveVault::Adapters
  class Base
    def self.connect(options)
      new(options)
    end
  end
end
