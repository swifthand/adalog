module Adalog
  module MockLoggingAdapter

    def self.new(service_name, repo, **stub_methods)
      new_logger_class = Class.new(self::Base)
      new_logger_class.instance_variable_set(:@service_name, service_name)
      new_logger_class.instance_variable_set(:@repo, repo)

      stub_methods.each do |message, value|
        new_logger_class.instance_exec do
          define_method(message, &->(*args, **kwargs, &block) {
            _received_messages << ReceivedMessage.new(message, args, kwargs, block)
            value
          })
        end
      end

      new_logger_class
    end


    ReceivedMessage = Struct.new(:message, :args, :kwargs, :block) do
      def name
        message
      end

      def arguments
        result  = []
        result += args
        result << kwargs unless kwargs.empty?
        result << block  unless nil == block
        result
      end
    end


    class Base

      class << self
        def service_name; @service_name ; end
        def repo        ; @repo         ; end
      end

      def initialize(**stub_method_overrides)
        stub_method_overrides.each do |message, value|
          define_singleton_method(message, &->(*args, **kwargs, &block) {
            _received_messages << ReceivedMessage.new(message, args, kwargs, block)
            value
          })
        end
      end


      def service_name; self.class.service_name ; end
      def repo        ; self.class.repo         ; end


      def messages
        _received_messages
      end


      def received?(message, exactly: :none, at_least: :none, at_most: :none)
        recv_count = _received_messages.find { |recv| recv.message == message }.count

        return recv_count == exactly unless :none == exactly
        # Substitute a default "at_least: 1" behavior for no options given.
        if :none == at_least and :none == at_most
          at_least = 1
        end

        result = true
        result = result && recv_count >= at_least unless :none == at_least
        result = result && recv_count <= at_most  unless :none == at_most
        result
      end


      def _received_messages
        @_received_messages ||= []
      end

    end

  end
end
