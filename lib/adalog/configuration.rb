module Adalog

  class Configuration

    RequiredSettings  = [:repo, :singleton].freeze
    UntouchedValue    = Object.new.freeze

    attr_accessor *RequiredSettings

    def initialize
      defaults.each_pair do |attr, value|
        self.send("#{attr}=", value)
      end
    end


    def defaults
      { repo:       Adalog::InMemoryRepo.new,
        singleton:  true,
      }
    end


    def web_defaults
      { repo: self.repo,
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
