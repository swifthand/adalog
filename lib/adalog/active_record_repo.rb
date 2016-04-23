module Adalog
  class ActiveRecordRepo

    attr_reader :record_class, :base_relation

    def initialize(record_class, **repo_options)
      @record_class   = record_class
      @base_relation  = determine_base_relation(repo_options)
    end


    def fetch(**options)
      where_options = options.fetch(:where, {})
      order_options = options.fetch(:order, :none)
      relation = relation_from_options(where_options, order_options)
      if options[:first]
        relation.first(options[:first])
      elsif options[:last]
        relation.last(options[:last])
      else
        relation.to_a
      end
    end


    def insert(attr_hash = {}, **attr_args)
      attrs   = attr_hash.merge(attr_args)
      record  = record_class.new(**attrs)
      if record.valid?
        if record.save
          [:ok, record]
        else
          wtf = "Unknown Non-validation error in call to #{record_class}#save"
          [:error, [wtf]]
        end
      else
        [:error, record.errors.full_messages]
      end
    end


    def all
      record_class.all.to_a
    end


  private ########################################################################


    def relation_from_options(where, order)
      relation = base_relation.dup
      relation = relation.where(where) if where.any?
      relation = relation.order(order) if order != :none
    end


    def determine_base_relation(options)
      options.fetch(:base_relation, record_class.unscoped)
    end

  end
end
