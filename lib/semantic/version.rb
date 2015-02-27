require 'forwardable'

module Semantic
  Version = Struct.new(*%i[ number prerelease meta ])
end

require 'semantic/version/number'
require 'semantic/version/data'

module Semantic

  class Version < Struct

    class << self

      def pattern
        /(?<number>\d+\.\d+\.\d+)(\-(?<prerelease>[^+]+))?(\+(?<meta>.+))?/
      end

      def parse(string)
        matches = string.match(pattern)
        (major, minor, patch), prerelease, meta = matches.captures.map{ |list| list.to_s.split('.') }
        new major: major, minor: minor, patch: patch, prerelease: prerelease, meta: meta
      end

      def read(file_path)
        file_path = Pathname.new(file_path) unless file_path.is_a? Pathname
        string = File.open(file_path) do |file|
          file.read.gsub(/\A[[:space:]]+/, '').gsub(/[[:space:]]+\z/, '').gsub(/[[:space:]]+/, ' ')
        end
        parse string
      end

    end

    def initialize(major: 0, minor: 0, patch: 0, prerelease: [], meta: [])
      super Number.new(major, minor, patch), Data.new(*prerelease), Data.new(*meta)
    end

    extend Forwardable
    def_delegators :number, :major, :minor, :patch, :stable?

    def bump(*args)
      clone.bump!(*args)
    end

    def bump!(*args, preserve: [], **opts)
      tap do |version|
        version.number.bump!(*args)
        preserve = Array(preserve)
        unless preserve.include? :all
          version.prerelease = nil unless preserve.include? :prerelease
          version.meta = nil unless preserve.include? :meta
        end
      end
    end

    def prerelease?
      not prerelease.to_a.compact.empty?
    end

    def prerelease= *array
      self[:prerelease] = array.flatten.compact.empty? ? nil : Data.new(*array.flatten)
    end

    def meta?
      not meta.to_a.compact.empty?
    end

    def meta= *array
      self[:meta] = array.flatten.compact.empty? ? nil : Data.new(*array.flatten)
    end

    def to_s
      number.to_s.tap do |version|
        version.concat '-' + prerelease if prerelease?
        version.concat '+' + meta       if meta?
      end
    end

    def to_str
      to_s
    end

    def clone
      self.class.new number.to_h.clone.merge(prerelease: prerelease.clone, meta: meta.clone)
    end


    include Comparable

    def <=> other
      %i[number prerelease].reduce(0) do |result, member|
        if not result.zero?
          result
        else
          self[member] <=> other[member]
        end
      end
    end

  end
end

require 'semantic/version/helper'

Semantic::Version.extend Semantic::Version::Helper
Semantic::Version.version from: Dir['*.version'].first
