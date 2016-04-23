require 'sinatra/base'

module Adalog
  class Web < Sinatra::Base

    def initialize(app = nil, web_options = {})
      super(app)
      options = default_options.merge(web_options)
      @repo   = options.fetch(:repo)
    end


    def default_options
      Adalog.configuration.web_defaults
    end


    get '/' do
      "Hello World!"
    end

  end
end
