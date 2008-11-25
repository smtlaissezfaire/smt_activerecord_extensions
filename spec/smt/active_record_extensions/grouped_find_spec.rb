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

        it "should use the hash given" do
          a_hash = { :foo => :bar }
          User.should_receive(:paginate).any_number_of_times.with(:all, hash_including(a_hash)).and_return []
          
          User.find_in_groups_of(2, a_hash) { |user| users << user }
        end
        
        it "should limit the results with the number given" do
          a_hash = { :foo => :bar }
          User.should_receive(:find).any_number_of_times.with(:all, hash_including(:limit => 2)).and_return []
          
          User.find_in_groups_of(2, a_hash) { |user| users << user }
        end
        
        it "should limit to the correct number" do
          a_hash = { :foo => :bar }
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
