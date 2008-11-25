module SMT
  module ActiveRecordExtensions
    module GroupedFind
      class WillPaginateError < StandardError; end
      
      # Using find(:all).each is often terrible inefficient.  It's a memory
      # hog.  Usually finding the records in groups, and then iterating through
      # those groups is a better solution.
      #
      # This wraps ActiveRecord::Base#find(:all), yielding each record as if
      # you had used find(:all).each { |record| }
      def find_in_groups_of(limit, options_hash={ })
        unless respond_to?(:paginate)
          raise WillPaginateError, "Will Paginate (or another pagination method) must be loaded"
        end
        
        empty_collection = false
        page = 1
        
        while !empty_collection
          collection = paginate(:all, options_hash.merge!(:page => page, :per_page => limit))
          empty_collection = collection.empty?
          
          collection.each do |record|
            yield(record)
          end
          page += 1
        end
      end
    end
  end  
end
