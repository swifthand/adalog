require 'sinatra/base'
module Adalog
  class Web < Sinatra::Base

    Config = Struct.new(:repo, :heading, :time_format)

    attr_reader :config

    def initialize(app = nil, web_options = {})
      super(app)
      options = default_options.merge(web_options)
      @config = Adalog::Web::Config.new
      determine_config_settings(config, options)
      sinatra_class_option_overrides(options)
    end


    def determine_config_settings(config, options)
      config.repo         = options.fetch(:repo)
      config.heading      = options.fetch(:heading)
      config.time_format  = options.fetch(:time_format)
    end


    def sinatra_class_option_overrides(options)
      if options.key?(:erb_layout)
        class_exec { set :erb, layout: options[:erb_layout] }
      end
      if options.key?(:views_folder)
        class_exec { set :views, options[:views_folder] }
      end
    end


    def default_options
      Adalog.configuration.web_defaults
    end


    set :root,  File.join(File.dirname(__FILE__), 'web')
    set :erb,   layout: :'adalog.html'
    set :views, File.join(File.dirname(__FILE__), 'web', 'views')


    helpers do

      def humanize_time(val)
        case val
        when DateTime, Time
          val.strftime(config.time_format)
        when String
          val
        else
          val.to_s
        end
      end


      def heading
        config.heading
      end


      def path_from_web_root(path)
        File.join(("#{env['SCRIPT_NAME']}/" || "/"), path)
      end

    end

    ##
    # The primary page that matters in this simple little log.
    get '/' do
      @entries = config.repo.all
      erb :'index.html'
    end

    ##
    # TODO: Maybe sort, do a forgiving attempt at date/time parsing and then
    #       filter based on that?
    # get '/after/:timestamp' do
    #   @entries = config.repo.all
    # end

    ##
    # TODO: Maybe sort, do a forgiving attempt at date/time parsing and then
    #       filter based on that?
    # get '/before/:timestamp' do
    #   @entries = config.repo.all
    # end


    ##
    # CONSIDER: Since this is all-destructive, should this be a confirmation
    #           page first and a followup action via post?
    post '/clear' do
      config.repo.clear!
      redirect to('/')
    end



  end
end
