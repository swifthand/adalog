Dir[File.join(File.dirname(__FILE__), "adalog", "*.rb")].each do |rb_file|
  require rb_file
end

module Adalog

  def self.configuration
    @configuration || ((configure! { :defaults }) && @configuration)
  end


  def self.configure
    config = Adalog::Configuration.new
    yield(config)
    config.validate!
    config.freeze
    @configuration = config
    post_configuration(@configuration)
    :ok
  end


  def self.post_configuration(config)
    if config.singleton
      self.extend(RepoConvenienceMethods)
    end
    if config.html_erb
      Tilt.register(Tilt::ERBTemplate, 'html.erb')
    end
  end


  module RepoConvenienceMethods

    def repo
      configuration.repo
    end

    def all
      configuration.repo.all
    end


    def clear!
      configuration.repo.clear!
    end


    def fetch(**options)
      configuration.repo.fetch(**options)
    end


    def insert(entry = nil, **options)
      configuration.repo.insert(entry, **options)
    end

  end

end
