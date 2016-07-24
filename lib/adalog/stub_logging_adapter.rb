module Adalog
  module StubLoggingAdapter

    ##
    # A factory to make new classes which implement the MockLogging
    def self.new(service_name, repo, **stub_methods)
      new_logger_class = Class.new(self::Base)
      new_logger_class.instance_variable_set(:@service_name, service_name)
      new_logger_class.instance_variable_set(:@repo, repo)

      stub_methods.each do |message, value|
        new_logger_class.instance_exec do
          define_method(message, &StubLoggingAdapter.stub_method(message, value))
        end
      end

      new_logger_class
    end

    ##
    # An isolated lambda to serve as the method body for stubs, both in
    # the ::new method and in the Base#initialize method.
    # Avoids repeating already clunky-looking logic.
    def self.stub_method(message, value)
      ->(*args, &block) {
        repo.insert(
          title:    service_name,
          message:  "'#{message}', which has been stubbed with '#{value}'.",
          details:  args)
        block.call unless nil == block
        value
      }
    end

    ##
    # Used as the superclass of all logging classes returned from ::new
    class Base

      ##
      # Store the service_name and repo at the class level rather than coming up with some
      # way of shoehorning it into each instance directly.
      class << self
        def service_name; @service_name ; end
        def repo        ; @repo         ; end
      end

      ##
      # Allows for overriding stubbed methods which were initially built into the mock adapter.
      # Does not explicitly restrict "overriding" to existing stubs, and so can be used to add
      # additional stubs to a specific instance.
      def initialize(**stub_method_overrides)
        stub_method_overrides.each do |message, value|
          define_singleton_method(message, &StubLoggingAdapter.stub_method(message, value))
        end
      end

      ##
      # Convenience instance method versions of class-level storage of service_name and repo.
      def service_name; self.class.service_name ; end
      def repo        ; self.class.repo         ; end

    end

  end
end
