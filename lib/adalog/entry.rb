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
          obj.to_h.merge(options)
        else
          { title:      obj.respond_to?(:title)     && obj.title,
            timestamp:  obj.respond_to?(:timestamp) && obj.timestamp,
            message:    obj.respond_to?(:message)   && obj.message,
            details:    obj.respond_to?(:details)   && obj.details,
            format:     obj.respond_to?(:format)    && obj.format,
          }.merge(options)
        end

      self.new(
        title:      arguments[:title]     || arguments['title'],
        timestamp:  arguments[:timestamp] || arguments['timestamp'],
        message:    arguments[:message]   || arguments['message'],
        details:    arguments[:details]   || arguments['details'],
        format:     arguments[:format]    || arguments['format'],
      )
    end

    attr_reader :title, :timestamp, :message, :details, :errors

    def initialize(title: nil, timestamp: nil, message: nil, details: nil, format: nil)
      @title      = title     || ''
      @timestamp  = timestamp || Time.now
      @message    = message   || ''
      @details    = details   || ''
      @format     = format    || 'json'
      validate!
    end


    def valid?
      @errors.none?
    end

    ##
    # TODO: Make this something we store and/or can override.
    def format
      :json
    end


    def details_blank?
      blank?(details)
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
