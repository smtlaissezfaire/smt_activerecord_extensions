require 'rubygems'
require 'active_record'
require File.dirname(__FILE__) + "/../lib/smt"

require 'rubygems'
require 'sqlite3'
require 'active_record'
require 'active_support'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :first_name
    t.string :last_name
    t.timestamps
  end
end

class User < ActiveRecord::Base; end
