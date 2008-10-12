require File.dirname(__FILE__) + "/../../spec_helper"

module SMT
  module ActiveRecordExtensions
    describe QueryCombiner do
      it "should initialize with an array" do
        QueryCombiner.new ["a = b", 7]
      end
    end
    
    describe QueryCombiner, "&" do
      it "should be able to be combined with another array with &" do
        one = QueryCombiner.new ["a = ?", 7]
        two = QueryCombiner.new ["b = ?", 9]
        (one & two).should == ["(a = ?) AND (b = ?)", 7, 9]
      end
      
      it "should always prefer the other's array values, and put them first" do
        one = QueryCombiner.new ["a = ? AND b = ? and c = ?", 1, 7]
        two = QueryCombiner.new ["x = ?", 2]
        (one & two).should == ["(a = ? AND b = ? and c = ?) AND (x = ?)", 1, 7, 2]
      end
      
      it "should be able to combine values from two arrays, which have no escaped values" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 8"]
        (one & two).should == ["(foo = 7) AND (bar = 8)"]
      end
      
      it "should be able to combine several queries, successively, as left-associative" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 7"]
        three = QueryCombiner.new ["baz = 7"]
        (one & two & three).should == ["((foo = 7) AND (bar = 7)) AND (baz = 7)"]
      end
      
      it "should return just the second element, if the first element is empty" do
        one = QueryCombiner.new []
        two = QueryCombiner.new ["foo = 7"]
        (one & two).should == ["foo = 7"]
      end
      
      it "should return just the first element, if the second element is empty" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new []
        (one & two).should == ["foo = 7"]
      end
    end
    
    describe QueryCombiner, "and" do      
      it "should be able to be combined with another array with and" do
        one = QueryCombiner.new ["a = ?", 7]
        two = QueryCombiner.new ["b = ?", 9]
        (one.and two).should == ["a = ? AND b = ?", 7, 9]
      end
      
      it "should always prefer the other's array values, and put them first" do
        one = QueryCombiner.new ["a = ? and b = ? and c = ?", 1, 7]
        two = QueryCombiner.new ["x = ?", 2]
        (one.and two).should == ["a = ? and b = ? and c = ? AND x = ?", 1, 7, 2]
      end
      
      it "should be able to combine values from two arrays, which have no escaped values" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 8"]
        (one.and two).should == ["foo = 7 AND bar = 8"]
      end
      
      it "should be able to combine several queries, successively, as right-associative" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 7"]
        three = QueryCombiner.new ["baz = 7"]
        (one.and(two).and(three)).should == ["foo = 7 AND bar = 7 AND baz = 7"]
      end
      
      it "should return just the second element, if the first element is empty" do
        one = QueryCombiner.new []
        two = QueryCombiner.new ["foo = 7"]
        (one.and two).should == ["foo = 7"]
      end
      
      it "should return just the first element, if the second element is empty" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new []
        (one.and two).should == ["foo = 7"]
      end
    end
    
    describe QueryCombiner, "or" do      
      it "should be able to be combined with another array with or" do
        one = QueryCombiner.new ["a = ?", 7]
        two = QueryCombiner.new ["b = ?", 9]
        (one.or two).should == ["a = ? OR b = ?", 7, 9]
      end
      
      it "should always prefer the other's array values, and put them first" do
        one = QueryCombiner.new ["a = ? and b = ? and c = ?", 1, 7]
        two = QueryCombiner.new ["x = ?", 2]
        (one.or two).should == ["a = ? and b = ? and c = ? OR x = ?", 1, 7, 2]
      end
      
      it "should be able to combine values from two arrays, which have no escaped values" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 8"]
        (one.or two).should == ["foo = 7 OR bar = 8"]
      end
      
      it "should be able to combine several queries, successively, as right-associative" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 7"]
        three = QueryCombiner.new ["baz = 7"]
        (one.or(two).or(three)).should == ["foo = 7 OR bar = 7 OR baz = 7"]
      end
      
      it "should return just the second element, if the first element is empty" do
        one = QueryCombiner.new []
        two = QueryCombiner.new ["foo = 7"]
        (one.or two).should == ["foo = 7"]
      end
      
      it "should return just the first element, if the second element is empty" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new []
        (one.or two).should == ["foo = 7"]
      end      
    end
    
    describe QueryCombiner, "|" do
      it "should be able to be combined with another array with &" do
        one = QueryCombiner.new ["a = ?", 7]
        two = QueryCombiner.new ["b = ?", 9]
        (one | two).should == ["(a = ?) OR (b = ?)", 7, 9]
      end
      
      it "should always prefer the other's array values, and put them first" do
        one = QueryCombiner.new ["a = ? AND b = ? and c = ?", 1, 7]
        two = QueryCombiner.new ["x = ?", 2]
        (one | two).should == ["(a = ? AND b = ? and c = ?) OR (x = ?)", 1, 7, 2]
      end
      
      it "should be able to combine values from two arrays, which have no escaped values" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 8"]
        (one | two).should == ["(foo = 7) OR (bar = 8)"]
      end
      
      it "should be able to combine several queries, successively, as left-associative" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new ["bar = 7"]
        three = QueryCombiner.new ["baz = 7"]
        (one | two | three).should == ["((foo = 7) OR (bar = 7)) OR (baz = 7)"]
      end
      
      it "should return just the second element, if the first element is empty" do
        one = QueryCombiner.new []
        two = QueryCombiner.new ["foo = 7"]
        (one | two).should == ["foo = 7"]
      end
      
      it "should return just the first element, if the second element is empty" do
        one = QueryCombiner.new ["foo = 7"]
        two = QueryCombiner.new []
        (one | two).should == ["foo = 7"]
      end
    end
  end
end
