module Adalog
  module MockLoggingAdapter

    ##
    # A factory to make new classes which implement the MockLogging
    def self.new(service_name, repo, **stub_methods)
      new_logger_class = Class.new(self::Base)
      new_logger_class.instance_variable_set(:@service_name, service_name)
      new_logger_class.instance_variable_set(:@repo, repo)

      stub_methods.each do |message, value|
        new_logger_class.instance_exec do
          define_method(message, &MockLoggingAdapter.stub_method(message, value))
        end
      end

      new_logger_class
    end

    ##
    # An isolated lambda to serve as the method body for stubs, both in
    # the ::new method and in the Base#initialize method.
    # Avoids repeating already clunky-looking logic.
    def self.stub_method(message, value)
      ->(*args, **kwargs, &block) {
        _received_messages << ReceivedMessage.new(message, args, kwargs, block)
        repo.insert(
          title:    service_name,
          message:  "'#{message}', which has been stubbed with '#{value}'.",
          details:  args)
        block.call unless nil == block
        value
      }
    end

    ##
    # A class to encapsulate the data logged for received messages and all
    # of their arguments.
    ReceivedMessage = Struct.new(:message, :args, :kwargs, :block) do

      ##
      # Just a little alias in case you're not as used to, or comfortable with,
      # referring to Ruby method calls as 'messages' that are sent and received.
      # But should be.
      # Because that's what they are.
      def name
        message
      end

      ##
      # A handy list of the received arguments, without the message name.
      def arguments
        result  = []
        result += args
        result << kwargs unless kwargs.empty?
        result
      end

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
          define_singleton_method(message, &MockLoggingAdapter.stub_method(message, value))
        end
      end

      ##
      # Convenience instance method versions of class-level storage of service_name and repo.
      def service_name; self.class.service_name ; end
      def repo        ; self.class.repo         ; end

      ##
      # Reader for the messages received by this mock, perhaps for use in testing
      # details of particular calls.
      def messages
        _received_messages
      end

      ##
      # For use in simple boolean asserts, if all you need to test is the number of
      # times a message was received. Flexible keyword arguments, which the the following
      # precedence and details:
      # - If :exactly is specified, will return true only if the message count is exactly the
      #   value of :exactly.
      # - When :exactly is specified, :at_least and :at_most are ignored.
      # - If :at_least is specified, will return true only if the message count is equal to or
      #   greater than the value of :at_least.
      # - If :at_most is specified, will return true only if the message count is equal to or
      #   less than the value of :at_most.
      # - :at_least and :at_most can be used simultaneously, and will return true if the
      #   message count falls in the range (at_least..at_most), that is, inclusive.
      # - If no keyword options are specified, the default behavior is equivalent to
      #   calling with the option `at_least: 1`.
      #
      # Consequently, this method is as flexible as possible, to allow for expressive
      # assertions in tests, such as:
      #   received?('unsubscribe', at_least: 1)
      #   received?('generate', exactly: 3)
      #   received?('toggle', at_least: 2, at_most: 4)
      #
      def received?(message, exactly: :none, at_least: :none, at_most: :none)
        recv_count = _received_messages.select { |recv| recv.message == message }.count

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

      ##
      # In case the service needs to stub-out a method named 'messages', we have
      # this more direct, internal method name.
      def _received_messages
        @_received_messages ||= []
      end

    end

  end
end
