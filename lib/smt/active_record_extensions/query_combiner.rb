module SMT
  module ActiveRecordExtensions
    # I'm an ActiveRecord Query Combiner.  I Combine fragments of sql arrays into new sql arrays, like so:
    #
    #   a1 = QueryCombiner.new ["a = ? or b = ?", 7, 9]
    #   a2 = QueryCombiner.new ["c = ?", 10]
    #   a1 & a2 => ["(a = ? or b = ?) AND c = ?", 7, 9, 10]
    # 
    # I'm especially helpful when SQL WHERE clauses need to be joined dynamically in Rails Apps.
    #
    # My "&" and "|" operations are left-associative.  They bind more tightly than my "and" and "or" operators
    # (just like ruby's && and || bind more tightly than "and" and "or").  The "&" and "|" operators wrap
    # their arguments in parenthesis, the "and" and "or" are a more simple concatination.
    #
    # These operators return a new QueryCombiner, but the QueryCombiner is a kind of Array, and can be treated
    # as such.
    class QueryCombiner < Array
      def &(other)
        if_not_empty(other) do
          QueryCombiner.new ["(#{query_string}) AND (#{other.query_string})", *combine_values(other)]
        end
      end
      
      def and(other)
        if_not_empty(other) do
          QueryCombiner.new ["#{query_string} AND #{other.query_string}", *combine_values(other)]
        end
      end
      
      def or(other)
        if_not_empty(other) do
          QueryCombiner.new ["#{query_string} OR #{other.query_string}", *combine_values(other)]
        end
      end
      
      def |(other)
        if_not_empty(other) do
          QueryCombiner.new ["(#{query_string}) OR (#{other.query_string})", *combine_values(other)]
        end
      end
      
    protected
    
      def if_not_empty(other)
        if self.empty?
          QueryCombiner.new other
        elsif other.empty?
          self
        else
          yield
        end
      end
    
      def combine_values(arg)
        self.values + arg.values
      end
      
      def values
        if self.empty?
          []
        else
          self[1..self.size]
        end
      end      
      
      def query_string
        self[0]
      end
      
    end
  end
end