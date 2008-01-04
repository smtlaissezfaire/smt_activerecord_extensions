module SMT
  module ActiveRecordExtensions
    module GroupedFind
      # Using find(:all).each is often terrible inefficient.  It's a memory
      # hog.  Usually finding the records in groups, and then iterating through
      # those groups is a better solution.
      #
      # This wraps ActiveRecord::Base#find(:all), yielding each record as if
      # you had used find(:all).each { |record| }
      def find_in_groups_of(num, hash={})
        number_of_items = self.count
        offset = 0

        while number_of_items > 0
          self.find(:all, hash.merge(:limit => num, :offset => offset)).each do |record|
            yield record
          end

          number_of_items -= num
          offset += num
        end
      end
    end
  end  
end
