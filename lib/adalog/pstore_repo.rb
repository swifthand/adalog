require 'pstore'

module Adalog
  class PStoreRepo

    attr_reader :storage

    def initialize(path, **repo_options)
      @storage  = PStore.new(path, true)
    end


    def fetch(**options)
      all
    end


    def all
      storage.transaction do
        storage.roots.flat_map do |key|
          storage.fetch(key, [])
        end
      end.reverse
    end


    def insert(entry = nil, **options)
      converted_entry = Adalog::Entry.build(entry, **options)
      if converted_entry.valid?
        insert_into_storage(converted_entry)
        [:ok, converted_entry]
      else
        [:error, converted_entry.errors]
      end
    end


    def clear!
      storage.transaction do
        all_keys = storage.roots
        all_keys.each do |key|
          storage.delete(key)
        end
      end
      :ok
    end


  private ######################################################################


    def insert_into_storage(entry)
      storage.transaction do
        key   = Time.now.to_i
        list  = storage.fetch(key, [])
        list.unshift(entry)
        storage[key] = list
      end
    end

  end
end
