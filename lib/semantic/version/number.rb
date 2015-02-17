require 'semantic/version/to_string'

module Semantic
  class Version
    class Number < Struct.new(*%i[ major minor patch ])

      include ToString

      def initialize(*args)
        super *args.map{ |number| Integer number }
      end

      def stable?
        major > 0
      end

      def bump(*args)
        clone.bump!(*args)
      end

      def bump!(level = :patch, by: 1, to: nil)
        tap do |number|
          if to
            number[level.to_sym] = to
          else
            number[level.to_sym] += by
          end
        end
      end

      include Comparable

      def <=> other
        members.reduce(0) do |result, member|
          if not result.zero?
            result
          else
            self[member] <=> other[member]
          end
        end
      end

    end
  end
end
