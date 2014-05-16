require 'test_helper'

# Tests a triple store
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class TripleStoreTest < ActiveSupport::TestCase

  context 'Empty Triple List:' do
    setup do
      @store = TripleStore.new([])
    end

    should "expect no subjects" do
      assert_equal [], @store.subjects('b','c')
    end
    should "expect no predicates" do
      assert_equal [],  @store.predicates('a','c')
    end
    should "expect no objects" do
      assert_equal [], @store.objects('a','b')
    end
  end

  context 'One-triple list:' do
    setup do
      @store = TripleStore.new([['a','b','c']])
    end

    should "expect one subject" do
      assert_equal ['a'], @store.subjects('b','c')
    end
    should "expect one predicate" do
      assert_equal ['b'],  @store.predicates('a','c')
    end
    should "expect one object" do
      assert_equal ['c'], @store.objects('a','b')
    end
    should "expect no subjects" do
      assert_equal [], @store.subjects('b','d')
    end
    should "expect no predicates" do
      assert_equal [],  @store.predicates('a','d')
    end
    should "expect no objects" do
      assert_equal [], @store.objects('a','d')
    end
  end

  context 'Four-triple list:' do
    setup do
      @store = TripleStore.new([['a','b','c'], ['a', 'b', 'd'],['a','e','d'],['f','e','d']])
    end

    # Subjects
    should "expect one subject for b-c" do
      assert_equal ['a'], @store.subjects('b','c')
    end
    should "expect one subject for b-d" do
      assert_equal ['a'], @store.subjects('b','d')
    end
    should "expect two subjects for e-d" do
      assert_equal ['a', 'f'], @store.subjects('e','d')
    end

    # Predicates
    should "expect one predicate for a-c" do
      assert_equal ['b'],  @store.predicates('a','c')
    end
    should "expect two predicates for a-d" do
      assert_equal ['b','e'],  @store.predicates('a','d')
    end
    should "expect one predicate for f-d" do
      assert_equal ['e'],  @store.predicates('f','d')
    end

    # Objects
    should "expect two objects for a-b" do
      assert_equal ['c', 'd'], @store.objects('a','b')
    end
    should "expect one object for a-e" do
      assert_equal ['d'], @store.objects('a','e')
    end
    should "expect one object for f-e" do
      assert_equal ['d'], @store.objects('f','e')
    end
  end

end
