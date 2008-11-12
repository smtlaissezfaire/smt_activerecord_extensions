module SMT
  module ActiveRecordExtensions
    module GroupedFind
      # Using find(:all).each is often terrible inefficient.  It's a memory
      # hog.  Usually finding the records in groups, and then iterating through
      # those groups is a better solution.
      #
      # This wraps ActiveRecord::Base#find(:all), yielding each record as if
      # you had used find(:all).each { |record| }
      def find_in_groups_of(limit, options_hash={ })
        def count_items(options)
          count_options = options.dup
          count_options.delete(:include)
          
          number_of_items = count(count_options.merge(:select => "*"))
          number_of_items.kind_of?(Numeric) ? number_of_items : count
        end
        
        number_of_items = count_items(options_hash)
        offset = 0
        
        while number_of_items > 0
          find(:all, options_hash.merge(:limit => limit, :offset => offset)).each do |record|
            yield record
          end
          
          number_of_items -= limit
          offset          += limit
        end
      end
    end
  end  
end
