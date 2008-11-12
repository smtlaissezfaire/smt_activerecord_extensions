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
        
        it "should use the total count of the table if count returns an [] (because there's a group condition)" do
          User.stub!(:count).and_return 2
          
          users = []
          user = User.create!(:first_name => "Scott")
          User.find_in_groups_of(1, :select => "users.*") { |user| users << user }
          users.should == [user]
        end
        
        it "should count the whole table if the original query returns an array" do
          User.should_receive(:count).with(:foo => :bar, :select => "*").and_return []
          User.should_receive(:count).with(no_args).and_return 0
          
          User.stub!(:find).and_return []
          
          User.find_in_groups_of(1, :foo => :bar) { }
        end
        
        it "should count the whole table if the original count of the first query returns something other than a number" do
          User.should_receive(:count).with(:foo => :bar, :select => "*").and_return Object.new
          User.should_receive(:count).with(no_args).and_return 0
          
          User.stub!(:find).and_return []
          
          User.find_in_groups_of(1, :foo => :bar) { }
        end
        
        it "should not raise an error on the count with an IN (?) clause" do
          User.create!
          user_ids = User.find(:all)
          
          lambda {
            User.find_in_groups_of(1, :conditions => ["users.id IN (?)", user_ids]) {}
          }.should_not raise_error
        end
        
        it "should not raise an error when an eager include is given" do
          User.create!
          user_ids = User.find(:all)
          
          lambda {
            User.find_in_groups_of(1, :conditions => ["users.id IN (?)", user_ids], :include => :comments) {}
          }.should_not raise_error
        end
        
        it "should not raise an error when a join is given" do |variable|
          user = User.create!
          user_ids = User.find(:all)
          user.comments.create!
          
          lambda {
            User.find_in_groups_of(1, :conditions => ["users.id IN (?)", user_ids], :joins => "INNER JOIN comments on comments.user_id = users.id") {}
          }.should_not raise_error
        end
        
        it "should find the correct number with a join" do
          user = User.create!
          user_ids = User.find(:all)
          2.times { user.comments.create! }
          
          counter = 0
          User.find_in_groups_of(1, :conditions => ["users.id IN (?)", user_ids], :joins => "OUTER JOIN comments on comments.user_id = users.id") { |user| counter += 1 }
          counter.should equal(2)
        end
        
        it "should find the correct number of users with an eager include" do
          user = User.create!
          user_ids = User.find(:all)
          2.times { user.comments.create! }
          
          counter = 0
          User.find_in_groups_of(1, :conditions => ["users.id IN (?)", user_ids], :joins => "OUTER JOIN comments on comments.user_id = users.id") { |user| counter += 1 }
          counter.should equal(2)
        end
      end
    end
  end
end
