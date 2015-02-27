require 'rake'

require 'highline/import'
require 'semantic/version'


module Semantic
  class Version
    module Tasks

      def levels
        %i[major minor patch]
      end
      def types
        {bump: :by, jump: :to}
      end

      def default_level
        :patch
      end
      def default_type
        :bump
      end
      def default_incrementor
        :by
      end
      def default_num
        1
      end


      def version
        @version ||= Semantic::Version.read version_filepath
      rescue
        nil
      end

      def version_filepath
        @version_filepath ||= Pathname.new find_version_file
      rescue
        nil
      end

      def find_version_file
        ENV['VERSION_FILE'] ||= begin
          candidates = Dir['*.version']
          case candidates.length
          when 0
            ask [
              'Specify a version file to read from.',
              'In the future you can avoid this by running `rake version:install`,',
              'or setting ENV["VERSION_FILE"] to a custom .version file location in your Rakefile.',
              ' > ',
            ].join("\n")
          when 1
            candidates.first
          else
            choose do |menu|
              menu.prompt = "Multiple possible version files found. Please select one."
              (0..candidates.length).each do |number|
                selection = candidates[number]
                menu.choice "#{number}: #{selection}" do
                  say "(In the future you can avoid this by setting ENV['VERSION_FILE'] in your Rakefile.)\n > "
                  selection
                end
              end
            end
          end
        end if @prompt_for_version_file
      end

      def update_version(type, level = default_level, incrementor = default_incrementor, num = default_num)
        say "#{type.to_s.capitalize.chomp('e')}ing #{version} to #{updated_version(type, level, incrementor, num)}..."
        File.write version_filepath, updated_version(type, level, incrementor, num)
      end

      def updated_version(type, level = default_level, incrementor = default_incrementor, num = default_num)
        if type == :release
          version.tap do |v|
            if version.prerelease?
              version.prerelease = nil
            else
              version.bump :patch
            end
          end
        else
          version.bump(level, incrementor => num)
        end
      end

      def generate_description(type, level = default_level, incrementor = default_incrementor, num = default_num)
        if type == :release
          [
            'Removes prerelease data or bumps patch level',
            version ? "(to v#{updated_version(type)})" : nil,
          ].compact.join(' ')
        else
          [
            "#{type.to_s.capitalize} #{level} level",
            (incrementor == :by and num == 1) ? nil : "#{incrementor} #{num}",
            version ? "(to v#{updated_version(type, level, incrementor, num)})" : nil,
          ].compact.join(' ')
        end
      end

    end
  end
end

include Semantic::Version::Tasks

desc [
  'Show version number in',
  version_filepath ? version_filepath : '.version file',
  version ? "(v#{version})" : nil,
].compact.join(' ')
task :version do
  say "#{version}"
end

namespace :version do

  desc 'Generates a .version file in the project root.'
  task :install, :version do |_, opts|

    gemspec_file = ENV['GEMSPEC_FILE'] ||= begin
      candidates = Dir['*.gemspec']
      case candidates.length
      when 0
        say [
          'No .gemspec file found.',
          'To auto-load gemspec information in future runs of `rake version:install`,',
          'set ENV["GEMSPEC_FILE"] to a .gemspec file location in your Rakefile.',
        ].join("\n")
      when 1
        candidates.first
      else
        choose do |menu|
          menu.prompt = "Multiple gemspec files found to name your .version file after. Please select one."
          (0..candidates.length).each do |number|
            selection = candidates[number]
            menu.choice "#{number}: #{selection}" do
              say ' > '
              selection
            end
          end
        end
      end
    end

    version_file = ENV['VERSION_FILE'] ||= if gemspec_file
      version_file = File.basename(gemspec_file, '.*') + '.version'
    else
      version_file = ask [
        'Specify a version file to create.',
        ' > ',
      ].join("\n")
    end

    version = opts[:version] ||= if gemspec_file
      load gemspec_file
      Gem::Specification.find_by_name(File.basename(gemspec_file, '.*')).version
    else
      '0.0.1'
    end

    File.write version_file, version
  end

  types.each do |type, incrementor|

    desc generate_description(type, default_level, types[default_type], default_num) if type == default_type
    task type do
      @prompt_for_version_file = true
      update_version(type, default_level, types[type], default_num)
    end

    namespace type do

      %i[major minor patch].each do |level|

        desc generate_description(type, level, types[type], default_num) if type == default_type and level != default_level
        task level do
          @prompt_for_version_file = true
          update_version(type, level, types[type], default_num)
        end

        namespace level do
          desc generate_description(type, level, types[type], 'the specified number') unless true # type == default_type
          task types[type], :num do |_, opts|
            @prompt_for_version_file = true
            update_version(type, level, types[type], Integer(opts[:num]))
          end
        end

      end

    end

  end

  desc generate_description(:release)
  task :release do
    @prompt_for_version_file = true
    update_version(:release)
  end

  task :number do
    @prompt_for_version_file = true
    say version.number
  end

  %i[prerelease meta].each do |data|

    task data do
      @prompt_for_version_file = true
      say version.send data
    end

    namespace data do

      task :clear do
        @prompt_for_version_file = true
        updated_version = version.tap do |v|
          v.send :"#{data}=", nil
        end
        File.write version_filepath, updated_version
      end

      task :set, :to do |_, opts|
        @prompt_for_version_file = true
        updated_version = version.tap do |v|
          v.send :"#{data}=", *opts[:to].split('.')
        end
        File.write version_filepath, updated_version
      end

      task :append, :element do |_, opts|
        @prompt_for_version_file = true
        updated_version = version.tap do |v|
          v.send(:"#{data}") << opts[:element]
        end
        File.write version_filepath, updated_version
      end

    end
  end

end
