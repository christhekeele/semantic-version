module Semantic
  class Version
    module ToString

      def to_s
        to_a.join('.')
      end

      def to_str
        to_s
      end
      
    end
  end
end
