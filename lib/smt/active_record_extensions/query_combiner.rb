module SMT
  module ActiveRecordExtensions
    class QueryCombiner < Array
      def &(other)
        QueryCombiner.new ["(#{query_string}) AND (#{other.query_string})", *combine_values(other)]
      end
      
      def and(other)
        QueryCombiner.new ["#{query_string} AND #{other.query_string}", *combine_values(other)]
      end
      
      def or(other)
        QueryCombiner.new ["#{query_string} OR #{other.query_string}", *combine_values(other)]
      end
      
      def |(other)
        QueryCombiner.new ["(#{query_string}) OR (#{other.query_string})", *combine_values(other)]
      end
      
    protected
    
      def combine_values(arg)
        self.values + arg.values
      end
      
      def values
        self[1..self.size]
      end      
      
      def query_string
        self[0]
      end
      
    end
  end
end