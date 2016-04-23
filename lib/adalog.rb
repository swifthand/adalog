Dir[File.join(File.dirname(__FILE__), "adalog", "*.rb")].each do |rb_file|
  require rb_file
end

module Adalog

  def self.configuration
    @configuration || ((configure! { :do_nothing }) && @configuration)
  end


  def self.configure!
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
      self.extend RepoConvenienceMethods
    end
  end


  module RepoConvenienceMethods

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
