require 'time'
require 'date'

module Adalog
  class Entry

    def self.build(obj = nil, **options)
      arguments =
        if nil == obj
          options
        elsif obj.is_a?(Hash) || obj.respond_to?(:[])
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
        title:      arguments[:title]     || arguments['title'],
        timestamp:  arguments[:timestamp] || arguments['timestamp'],
        message:    arguments[:message]   || arguments['message'],
        details:    arguments[:details]   || arguments['details'],
      )
    end

    attr_reader :title, :timestamp, :message, :details, :errors

    def initialize(title: nil, timestamp: nil, message: nil, details: nil)
      @title      = title     || ''
      @timestamp  = timestamp || Time.now
      @message    = message   || ''
      @details    = details   || ''
      validate!
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
