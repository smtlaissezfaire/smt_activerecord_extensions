require File.dirname(__FILE__) + "/../../spec_helper"

module SMT
  module ActiveRecordExtensions
    describe GroupedFind do
      describe "finding a record" do
        it "should find the first record with no hash" do
          u = User.create!
          users = []
          User.find_in_groups_of(1) { |user| users << user }
          users.should == [u]
        end
        
        it "should find two records" do
          u1 = User.create!
          u2 = User.create!
          users = []
          
          User.find_in_groups_of(2) { |user| users << user }
          
          users.should == [u1, u2]
        end

        it "should use the has given" do
          a_hash = { :foo => :bar }
          User.stub!(:count).and_return 1
          User.should_receive(:find).any_number_of_times.with(:all, hash_including(a_hash)).and_return []
          
          User.find_in_groups_of(2, a_hash) { |user| users << user }
        end
        
        it "should limit the results with the number given" do
          a_hash = { :foo => :bar }
          User.stub!(:count).and_return 1
          User.should_receive(:find).any_number_of_times.with(:all, hash_including(:limit => 2)).and_return []
          
          User.find_in_groups_of(2, a_hash) { |user| users << user }
        end
        
        it "should limit to the correct number" do
          a_hash = { :foo => :bar }
          User.stub!(:count).and_return 1
          User.should_receive(:find).any_number_of_times.with(:all, hash_including(:limit => 3)).and_return []
          
          User.find_in_groups_of(3, a_hash) { |user| users << user }
        end
        
        it "should find both records, when given find_in_groups_of(1)" do
          u1 = User.create!
          u2 = User.create!
          users = []
          
          User.find_in_groups_of(1) { |user| users << user }
          
          users.should == [u1, u2]
        end
        
        it "should only call find once for one record when finding in groups of 1" do
          User.create!
          User.should_receive(:find).once.with(any_args).and_return [mock('user')]
          User.find_in_groups_of(1) { |user| }
        end
        
        it "should call find twice for two records, when finding in groups of 2" do
          2.times { User.create! }
          User.should_receive(:find).twice.with(any_args).and_return [mock('user')]
          User.find_in_groups_of(1) { |user| }
        end
        
        it "should only call find once for one record when finding in groups of 2" do
          u1 = User.create!(:first_name => "Scott")
          u2 = User.create!(:first_name => "John")
          
          User.should_receive(:find).once.and_return [u1]
          
          hash = {
            :conditions => ["first_name = ?", "Scott"]
          }

          User.find_in_groups_of(2, hash) { |user| }
        end
        
        it "should only call find once for one record when finding in groups of 1" do
          u1 = User.create!(:first_name => "Scott")
          u2 = User.create!(:first_name => "John")
          
          User.should_receive(:find).once.and_return [u1]
          
          hash = {
            :conditions => ["first_name = ?", "Scott"]
          }
          
          User.find_in_groups_of(1, hash) { |user| }
        end
        
        it "should return the correct result set when finding 4 records, two at a time" do
          User.stub!(:count).and_return 4
          User.should_receive(:find).twice.and_return([mock('a user'), mock('a user')])
          User.find_in_groups_of(2) { |user| }
        end
        
        it "should use count(*), even when passed a series of column names" do
          User.should_receive(:count).with({:select => "*"}).and_return 0
          User.find_in_groups_of(2, {:select => "foo.*"})
        end
        
        it "should find the records with count(column_name)" do
          user = User.create!(:first_name => "Scott")
          users = []
          User.find_in_groups_of(1, :select => "users.*") { |user| users << user }
          users.should == [user]
        end
      end
    end
  end
end
