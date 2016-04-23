module Adalog
  class InMemoryRepo

    attr_reader :storage

    def initialize(**repo_options)
      @storage = Array.new
    end


    def fetch(**options)
      all
    end


    def insert(entry = nil, **options)
      converted_entry = Adalog::Entry.build(entry = nil, **options)
      if converted_entry.valid?
        storage.unshift(converted_entry)
        [:ok, converted_entry]
      else
        [:error, converted_entry.errors]
      end
    end


    def clear!
      @storage = Array.new
      :ok
    end


    def all
      return storage.dup
    end

  end
end
