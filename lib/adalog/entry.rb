require 'time'
require 'date'

module Adalog
  class Entry

    def self.build(obj = nil, **options)
      arguments =
        if nil == obj
          options
        elsif obj.is_a?(Hash)
          obj
        elsif obj.respond_to?(:to_h)
          obj.to_h
        else
          { title:      obj.respond_to?(:title)     && obj.title,
            timestamp:  obj.respond_to?(:timestamp) && obj.timestamp,
            message:    obj.respond_to?(:message)   && obj.message,
            details:    obj.respond_to?(:details)   && obj.details,
          }
        end

      self.new(
        title:      options[:title]     || options['title'],
        timestamp:  options[:timestamp] || options['timestamp'],
        message:    options[:message]   || options['message'],
        details:    options[:details]   || options['details'],
      )
    end

    attr_reader :title, :timestamp, :message, :details, :errors

    def initialize(title: nil, timestamp: nil, message: nil, details: nil)
      @title      = title
      @timestamp  = timestamp || DateTime.now
      @message    = message
      @details    = details
      validate!
    end


    def human_time
      case timestamp
      when DateTime, Time
        timestamp.strftime(Adalog.configuration.time_format)
      when String
        timestamp
      else
        timestamp.to_s
      end
    end


    def valid?
      @errors.none?
    end


  private ######################################################################


    def validate!
      @errors = []
      errors << content_error if no_content?
    end


    def content_error
      "Must have at least one of: 'title', 'message', 'details'."
    end


    def no_content?
      blank?(title) && blank?(message) && blank?(details)
    end


    def blank?(val)
      nil == val || '' == val
    end

  end
end
