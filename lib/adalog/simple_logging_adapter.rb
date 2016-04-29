module Adalog
  class SimpleLoggingAdapter

    attr_reader :service_name, :repo

    def initialize(service_name, repo)
      @service_name = service_name
      @repo         = repo
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
