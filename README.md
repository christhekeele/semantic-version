Semantic::Version
=================

> *Semantic version objects for Ruby.*

A utility library that provides a `Semantic::Version` value object.


You can parse strings into version objects or construct them by hand. Any module, class, or object can be given a version through a helper. All version objects properly handle instantiation, duplication, cloning, accessors, mutators, stringification, and comparison; and come with helpful predicate methods.


Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'semantic-version'
```

And then execute:

```sh
bundle
```

You can also version your gem with it.

1. Create or modify your version file:

  ```diff
  # lib/my_gem/version.rb

  +require 'semantic/version'

  module MyGem
  -  VERSION = '0.0.1'
  +  extend Semantic::Version::Helper
  +  version '0.0.1'
  end
  ```

2. Modify your gemspec:

  ```diff
  # my_gem.gemspec

  #...
  require 'my_gem/version'

  Gem::Specification.new do |spec|
    #...
  -   spec.version = MyGem::VERSION
  +   spec.version = MyGem.version
    #...
    spec.add_dependency "semantic-version", "~> 2.0.0"
    #...
  end
  ```

3. Update your `Gemfile.lock` by executing:

  ```sh
  bundle
  ```

There is currently no advantage to using `Semantic::Version` objects in your gemspec, except to declare to the world that your gem is semantic versioning compliant. There is also a `semantic-version-tasks` Rakefile plugin.


Usage
-----

Versions can be parsed from strings, or constructed piecewise:

```ruby
Semantic::Version.parse '1.0.0'
Semantic::Version.new major: 1, minor: 0, patch: 0
# => #<struct Semantic::Version
#      number=#<struct Semantic::Version::Number major=1, minor=0, patch=0>,
#      prerelease=[],
#      meta=[]
#    >
```

Versions can have multiple pre-release and meta tags:

```ruby
Semantic::Version.parse '1.0.0-alpha.12+build.2981'
Semantic::Version.new major: 1, minor: 0, patch: 0, prerelease: %w[alpha 12], meta: %w[build 2981]
# => #<struct Semantic::Version
#      number=#<struct Semantic::Version::Number major=1, minor=0, patch=0>,
#      prerelease=["alpha", 12],
#      meta=["build", 2981]
#    >
```

They properly display as strings:

```ruby
Semantic::Version.parse('1.0.0').to_s
#=> "1.0.0"
Semantic::Version.parse('1.0.0-alpha.12').to_s
#=> "1.0.0-alpha.12"
Semantic::Version.parse('1.0.0-alpha.12+build.2981').to_s
#=> "1.0.0-alpha.12+build.2981"
```

They come with useful accessors, mutators, and predicates:

```ruby
version = Semantic::Version.new

version.number.to_s
#=> "0.0.0"

version.bump.number.to_s
#=> "0.0.1"
version.bump(:minor).number.to_s
#=> "0.1.0"
version.bump(:major, by: 2).number.to_s
#=> "2.0.0"
version.bump(:major, to: 20).number.to_s
#=> "20.0.0"

version.bump!
version.number.to_s
#=> "0.0.1"
version.stable?
#=> false
version.bump!(:major, to: 1)
version.stable?
#=> true

version.prerelease.to_s
#=> ""
version.prerelease?
#=> false
version.prerelease = "alpha"
version.prerelease.to_s
#=> "alpha"
version.prerelease?
#=> true
version.prerelease << 12
version.prerelease.to_s
#=> "alpha.12"

version.meta.to_s
#=> ""
version.meta?
#=> false
version.meta = %w[build 2981]
version.meta.to_s
#=> "build.2981"
version.meta?
#=> true
version.meta += %w[sha e796e5da1f40820dcf5dab85487dd9e9a32f27e8]
version.meta.to_s
#=> "build.2981.sha.e796e5da1f40820dcf5dab85487dd9e9a32f27e8"

version.to_s
#=> "1.0.1-alpha.12+build.2981.sha.e796e5da1f40820dcf5dab85487dd9e9a32f27e8"
version.bump.to_s
#=> "1.0.2"
version.bump(preserve: :prerelease).to_s
#=> "1.0.2-alpha.12"
version.bump(preserve: :meta).to_s
#=> "1.0.2+build.2981.sha.e796e5da1f40820dcf5dab85487dd9e9a32f27e8"
version.bump(preserve: %i[prerelease meta]).to_s
#=> "1.0.2-alpha.12+build.2981.sha.e796e5da1f40820dcf5dab85487dd9e9a32f27e8"
version.bump(preserve: :all).to_s
#=> "1.0.2-alpha.12+build.2981.sha.e796e5da1f40820dcf5dab85487dd9e9a32f27e8"
```

Most importantly, they are properly comparable per the Semantic Version spec:

```ruby
Semantic::Version.parse('1.0.0+build.1') == Semantic::Version.parse('1.0.0+build.2')
#=> true

%w[
  1.0.0-alpha
  1.0.0-alpha.1
  1.0.0-alpha.beta
  1.0.0-beta
  1.0.0-beta.2
  1.0.0-beta.11
  1.0.0-rc.1
  1.0.0
  2.0.0
  2.1.0
  2.1.1
].map do |string|
  Semantic::Version.parse string
end.reduce do |smaller, greater|
  raise unless smaller < greater
  greater
end.to_s
#=> 2.1.1
```

Finally, you can give any module, class, or object a version with a simple helper:

```ruby
module MyGem

  extend Semantic::Version::Helper
  version '2.0.0' # or self.version = '2.0.0'

end

MyGem.version
#=> #<struct MyAPI::Version
#     number=#<struct Semantic::Version::Number major=2, minor=0, patch=0>,
#     prerelease=[],
#     meta=[]
#   >

class MyAPI

  include Semantic::Version::Helper
  def initialize(version: '0.0.1')
    self.version = version
  end

  include Comparable
  def <=> other
    version <=> other.version
  end

end

api1 = MyAPI.new
#=> #<MyAPI:0x007fb1fb9115e0
#    @version= #<struct MyAPI::Version
#      number=#<struct Semantic::Version::Number major=0, minor=0, patch=1>,
#      prerelease=[],
#      meta=[]
#    >
#  >
api1.version.to_s
#=> "0.0.1"
api2 = MyAPI.new(version: '0.0.2')
api1 < api2
#=> true
```

Take care to never use `attr_accessor` in conjunction with `version` when using this helper, or the coercion magic will be ruined.


Tasks
-----

By adding a version file to your gem's root directory you can use rake tasks to manage your versioning.

1. Add the helper tasks to your Rakefile:

  ```ruby
  #...
  require 'semantic/version/tasks'
  ```

2. Create a new version file for your project by executing:

  ```sh
  rake version:install
  ```

3. Reconfigure your gem to use the version file:

  ```diff
  # lib/my_gem/version.rb

  require 'semantic/version'

  module MyGem
    extend Semantic::Version::Helper
  -  version '0.0.1'
  +  version from: 'my_gem.version'
  end
  ```

High-level tasks are visible in your task list:

```bash
rake -T
rake version:install[version]  # Generates a .version file in the project root
                               #  'version' defaults to what's in your gemspec or 0.0.1
rake version                   # Show version number in semantic-version.version (v2.0.0-alpha.2)
rake version:release           # Removes prerelease data or bumps patch level (to v2.0.0)
rake version:bump              # Bump patch version by 1 (to v2.0.1)
rake version:bump:minor        # Bump minor version by 1 (to v2.1.0)
rake version:bump:major        # Bump major version by 1 (to v3.0.0)
```

There are also hidden tasks for querying and manipulating the version number, namely:

```bash
rake version:number                             # Shows version number only
rake version:(prerelease|meta)                  # Shows data type only
rake version:(prerelease|meta):clear            # Clears out data
rake version:(prerelease|meta):set[to]          # Changes data
rake version:(prerelease|meta):append[element]  # Appends element to data
```

Finally, lower-level number manipulation tasks are available following the formula:

```bash
rake version:(bump|jump):(patch|minor|major):(by|to)[num] # default num is 1
```

So, `rake version:bump:major:by[2]` will take you from `v2.0.0-alpha.2` to `v4.0.0`, and `rake version:jump:minor:to` will take you from `v2.0.0-alpha.2` to `v2.1.0`.


Contributing
------------

1. Fork it ( https://github.com/[my-github-username]/semantic-version/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
