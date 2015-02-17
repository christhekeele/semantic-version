module Semantic
  class Version
    module Helper

      def version(number=nil, from: nil)
        if number
          self.version = number
        elsif from
          self.version = version_class.read(from)
        else
          @version
        end
      end

      def version= number
        @version ||= case number
        when String
          version_class.parse(number)
        when version_class
          number
        when ::Semantic::Version
          data = number.to_h
          version_class.new data.merge(data.delete(:number).to_h)
        else
          raise "version must be a string or instance of `Semantic::Version`."
        end
      end

    private

      def version_namespace
        respond_to?(:const_get) ? self : self.class
      end

      def version_class
        unless (version_namespace.const_get :Version rescue false)
          version_namespace.const_set :Version, Class.new(::Semantic::Version)
        end
        version_namespace.const_get :Version
      end

    end
  end
end
