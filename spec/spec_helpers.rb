
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :first_name
    t.string :last_name
    t.timestamps
  end
end

class User < ActiveRecord::Base; end

class ActiveRecord::Base
  def self.subclasses
    @@subclasses[ActiveRecord::Base]
  end
end

module TestUnitRemover
  def self.remove!
    require "active_record"

    if defined?(Test)
      Object.instance_eval do
        remove_const(:Test)
      end
    end
  end
end


