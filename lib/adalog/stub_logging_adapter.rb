module Adalog
  module StubLoggingAdapter

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

    class Base

      ##
      # Store the service_name and repo at the class level rather than coming up with some
      # way of shoehorning it into each instance directly.
      class << self
        def service_name; @service_name ; end
        def repo        ; @repo         ; end
      end

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
