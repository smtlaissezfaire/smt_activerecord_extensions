require 'rubygems'
require 'spec'
require 'active_record'
require 'active_support'
require 'sqlite3'

require File.dirname(__FILE__) + "/../lib/smt"
require File.dirname(__FILE__) + "/spec_helpers"

Spec::Runner.configure do |config|
  config.prepend_before(:each) do
    ActiveRecord::Base.subclasses.each do |subclass|
      subclass.delete_all
    end
  end
end

TestUnitRemover.remove!
