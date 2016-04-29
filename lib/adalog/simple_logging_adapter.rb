module Adalog
  module SimpleLoggingAdapter

    def self.new(service_name, repo)
      new_logger_class = Class.new(self::Base)
      new_logger_class.instance_variable_set(:@service_name, service_name)
      new_logger_class.instance_variable_set(:@repo, repo)
      new_logger_class
    end


    class Base

      class << self
        def service_name; @service_name ; end
        def repo        ; @repo         ; end
      end

      attr_reader :service_name, :repo

      def initialize(*args, **kwargs, &block)
        @service_name = self.class.service_name
        @repo         = self.class.repo
      end

      ##
      # TODO: Record something w.r.t. whether or not a block is given?
      def method_missing(msg, *args, &block)
        repo.insert(
          title:    service_name,
          message:  msg,
          details:  args)
      end
    end

  end
end
