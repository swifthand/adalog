require 'sinatra/base'
module Adalog
  class Web < Sinatra::Base

    attr_reader :repo, :time_format

    def initialize(app = nil, web_options = {})
      super(app)
      options       = default_options.merge(web_options)
      @repo         = options.fetch(:repo)
      @heading      = options.fetch(:heading)
      @time_format  = options.fetch(:time_format)
    end


    def default_options
      Adalog.configuration.web_defaults
    end


    set :root,  File.join(File.dirname(__FILE__), 'web')
    set :erb,   layout: :adalog

    get '/' do
      @entries = repo.all
      erb :index
    end

    helpers do

      def human_time(val)
        val.strftime(time_format)
      end

      def heading
        @heading
      end

    end

  end
end
