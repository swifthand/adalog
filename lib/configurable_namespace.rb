class ConfigurableNamespace < Module
  VERSION = '1.0.0' # Extract to a version.rb file if this gem becomes more complex.

  class ConfigurationError < RuntimeError; end

  def initialize(settings: , required: [], defaults: {})
    @config_struct    = Struct.new(*settings)
    @config_required  = required
    @config_defaults  = defaults
  end


  def included(base)
    base.const_set(:ConfigStruct,   @config_struct)
    base.const_set(:ConfigRequired, @config_required)
    base.const_set(:ConfigDefaults, @config_defaults)
    base.extend(ClassMethods)
  end


  def inspect
    "#<#{self.name}, configurable settings:[#{@config_struct.members.join(', ')}]>"
  end


private ########################################################################

  module ClassMethods
    UntouchedValue = Object.new.freeze

    def configure
      # Build a config object loaded with UntouchedValue singletons and defaults.
      untouched_settings  = Array.new(self::ConfigStruct.members.count, UntouchedValue)
      config              = self::ConfigStruct.new(*untouched_settings)
      self::ConfigDefaults.each_pair do |key, val|
        config[key] = val
      end
      # Define attr_reader-style module instance methods that are not already defined.
      self::ConfigStruct.members.each do |setting|
        next if self.instance_methods.include?(setting)
        self.class_eval("def self.#{setting}; @#{setting}; end")
      end
      # Let the consumer configure themselves via setting values on the ConfigStruct.
      yield(config)
      # For any that were touched, set the instance variable.
      config.each_pair do |key, val|
        if val != UntouchedValue
          self.instance_variable_set("@#{key}", val)
        end
      end
      # Enforce any requirements we might have.
      enforce_configuration!
    end


    def enforce_configuration!
      missing = self::ConfigRequired.select do |attr|
        !self.respond_to?(attr) || self.send(attr).nil?
      end
      if missing.any?
        raise ConfigurationError.new("#{self.name} missing required configuration values: #{missing.join(', ')}.")
      else
        :ok
      end
    end
  end

end
