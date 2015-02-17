require 'semantic/version/to_string'

module Semantic
  class Version
    class Data < Array

      include ToString

      def initialize(*args)
        super args.compact.map{ |element| Integer(element) rescue element }
      end

      include Comparable

      def <=> other
        if [self, other].any?(&:empty?)
          other.length <=> length # no data always wins
        else
          myself = to_a
          if myself.length < other.length
            myself << nil until myself.length == other.length
          end
          myself.zip(other).reduce(0) do |result, (mine, theirs)|
            if not result.zero?
              result
            else
              if mine.class == theirs.class
                mine <=> theirs
              elsif String === mine
                return 1
              else
                return -1
              end
            end
          end
        end
      end

    end
  end
end
