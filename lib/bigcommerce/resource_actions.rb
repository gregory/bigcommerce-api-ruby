module Bigcommerce
  class ResourceActions < Module
    attr_reader :options

    def initialize(options = {})
      @options = options
      tap do |mod|
        mod.define_singleton_method :_options do
          mod.options
        end
      end
    end

    def included(base)
      base.send(:include, Request.new(options[:uri]))
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
      options[:disable_methods] ||= []
      methods = ClassMethods.public_instance_methods & options[:disable_methods]
      methods.each { |name| base.send(:remove_method, name) }
    end

    module InstanceMethods
      def save
        params = strip_read_only_fields(self.to_hash).merge(client: client)
        self.class.update(id, params)
      end

      def destroy
        self.class.destroy(id, client: client)
      end

      def strip_read_only_fields(params)
        self.class.read_only_fields.each { |field| params.delete(field) }
        params
      end
    end

    module ClassMethods
      def read_only(field)
        read_only_fields << field
        property field
      end

      def read_only_fields
        @read_only_fields ||=[]
      end

      def all(params = {})
        get path.build, params
      end

      def find(resource_id)
        fail ArgumentError if resource_id.nil?
        get path.build(resource_id)
      end

      def create(params)
        post path.build, params
      end

      def update(resource_id, params)
        fail ArgumentError if resource_id.nil?
        put path.build(resource_id), params
      end

      def destroy(resource_id)
        fail ArgumentError if resource_id.nil?
        delete path.build(resource_id)
      end

      def destroy_all
        delete path.build
      end
    end
  end
end
