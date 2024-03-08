module Revolut
  class Resource
    class << self
      def create(**attrs)
        check_not_allowed

        response = http_client.post("/#{resource_name}", data: attrs)

        body = response.body

        return body.map(&self) if body.is_a?(Array)

        new(body)
      end

      def retrieve(id)
        check_not_allowed

        response = http_client.get("/#{resource_name}/#{id}")

        new(response.body)
      end

      def update(id, **attrs)
        check_not_allowed

        response = http_client.patch("/#{resource_name}/#{id}", data: attrs)

        new(response.body)
      end

      def list(**)
        check_not_allowed

        response = http_client.get("/#{resources_name}", **)

        response.body.map(&self)
      end

      def delete(id)
        check_not_allowed

        http_client.delete("/#{resource_name}/#{id}")

        true
      end

      def to_proc
        ->(attrs) { new(attrs) }
      end

      def skip_coertion_for(*attrs)
        @skip_coertion_for ||= attrs
      end

      def coerce_with(**attrs)
        @coerce_with ||= attrs
      end

      def http_client
        @http_client ||= Revolut::Client.instance
      end

      protected

      def resource_name
        resources_name
      end

      def resources_name
        raise Revolut::NotImplementedError, "Implement #resources_name in subclass"
      end

      def not_allowed_to(*attrs)
        @not_allowed_to ||= attrs
      end

      def shallow
        # Adding :shallow will make all other resource methods fail.
        only :shallow
      end

      def only(*attrs)
        @only ||= attrs
      end

      private

      def check_not_allowed
        method = caller(1..1).first.match(/`(\w+)'/)[1].to_sym
        raise Revolut::UnsupportedOperationError, "`#{method}` operation is not allowed on this resource" if not_allowed_to.include?(method) || only.any? && !only.include?(method)
      end
    end

    def initialize(attrs = {})
      @_raw = attrs

      attrs.each do |key, value|
        if self.class.skip_coertion_for.include?(key.to_sym)
          instance_variable_set(:"@#{key}", value)
        else
          coerce_class = self.class.coerce_with[key.to_sym] || Revolut::Resource
          coerced_value = if value.is_a?(Hash)
            coerce_class.new(value)
          elsif value.is_a?(Array)
            value.map do |v|
              v.is_a?(Hash) ? coerce_class.new(v) : v
            end
          else
            value
          end
          instance_variable_set(:"@#{key}", coerced_value)
        end
      end

      instance_variables.each { |iv| self.class.send(:attr_accessor, iv.to_s[1..].to_sym) }
    end

    def to_json
      @_raw.to_json
    end
  end
end
