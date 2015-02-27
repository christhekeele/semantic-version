require 'bundler/gem_tasks'
require 'semantic/version/tasks'

desc 'Open a pry console preloaded with this library'
task console: 'console:pry'

namespace :console do

  task :pry do
    sh 'bundle exec pry -I lib -r semantic/version.rb'
  end

  task :irb do
    sh 'bundle exec irb -I lib -r semantic/version.rb'
  end

end
