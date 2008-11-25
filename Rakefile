
# To get this rakefile to run, you'll need to run the following
# commands in this project root:
#
# git submodule init
# git submodule update
#

PROJECT_PATHNAME          = "fixture_replacement"
PROJECT_ROOT              = File.dirname(__FILE__)

def project_pathname
  PROJECT_PATHNAME
end

def project_root
  PROJECT_ROOT
end

rake_tasks =  File.dirname(__FILE__) + "/vendor/smt_rake_tasks"

require "#{rake_tasks}/spec"
require "#{rake_tasks}/rspec_rcov"
require "#{rake_tasks}/flog"

task :default => :spec
