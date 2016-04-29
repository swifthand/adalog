module Adalog

  class Configuration

    RequiredSettings  = [:repo, :singleton, :html_erb, :time_format, :web_heading].freeze
    UntouchedValue    = Object.new.freeze

    attr_accessor *RequiredSettings

    def initialize
      defaults.each_pair do |attr, value|
        self.send("#{attr}=", value)
      end
    end


    def defaults
      { repo:         Adalog::InMemoryRepo.new,
        singleton:    true,
        html_erb:     true,
        time_format:  "%H:%M:%S - %d %b %Y",
        web_heading:  "Stub Adapter Logs",
      }
    end


    def web_defaults
      { repo:         self.repo,
        time_format:  self.time_format,
        heading:      self.web_heading,
      }
    end


    def validate!
      RequiredSettings.each do |required_attr|
        if UntouchedValue == self.send(required_attr)
          raise "Setting '#{required_attr}' for Adalog left unconfigured."
        end
      end
    end


  end

end
