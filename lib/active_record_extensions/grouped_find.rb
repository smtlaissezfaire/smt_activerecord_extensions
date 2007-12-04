module ActiveRecordExtensions
  module GroupedFind
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