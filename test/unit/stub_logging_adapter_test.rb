require 'test_helper'

class StubLoggingAdapterTest < Minitest::Test

  def setup
    @default_repo = Adalog::InMemoryRepo.new
  end


  def default_repo
    @default_repo ||= Adalog::InMemoryRepo.new
  end


################################################################################


  test "new creates a logging adapter class" do
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo)
    assert_kind_of(Class, adapter_class)
  end


  test "class accessors for service_name and repo" do
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo)
    assert_respond_to(adapter_class, :service_name)
    assert_respond_to(adapter_class, :repo)
    adapter = adapter_class.new
    assert_equal('SomeService', adapter.service_name)
    assert_equal(default_repo, adapter.repo)
  end


  test "instance methods are created for stubs specified in new" do
    stub_methods  = { foo: 'bar', one: 1, two: 2 }
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo, **stub_methods)
    adapter       = adapter_class.new
    assert_respond_to(adapter, :foo)
    assert_respond_to(adapter, :one)
    assert_respond_to(adapter, :two)
  end


  test "stubbed instance methods return provided stubbed values" do
    stub_methods  = { foo: 'bar', one: 1, two: 2 }
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo, **stub_methods)
    adapter       = adapter_class.new
    assert_equal('bar', adapter.foo)
    assert_equal(1,     adapter.one)
    assert_equal(2,     adapter.two)
  end


  test "new stubs can be added at instantiation" do
    stub_methods  = { foo: 'bar', one: 1, two: 2 }
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo, **stub_methods)
    adapter       = adapter_class.new(baz: 'bim')
    assert_respond_to(adapter, :baz)
    assert_equal('bim', adapter.baz)
  end


  test "stubs can be overridden at instantiation" do
    stub_methods  = { foo: 'bar', one: 1, two: 2 }
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo, **stub_methods)
    adapter       = adapter_class.new(foo: 'rofl')
    assert_respond_to(adapter, :foo)
    assert_equal('rofl', adapter.foo)
  end


  test "calls to stubs are stored in the repo" do
    stub_methods  = { foo: 'bar', one: 1, two: 2 }
    adapter_class = Adalog::StubLoggingAdapter.new('SomeService', default_repo, **stub_methods)
    adapter       = adapter_class.new

    adapter.foo('rofl', 'copter')
    entry = default_repo.all.first
    assert_equal("'foo', which has been stubbed with 'bar'.", entry.message)
    assert_equal(['rofl', 'copter'], entry.details)
    assert_equal('SomeService', entry.title)

    adapter.one
    entry = default_repo.all.first
    assert_equal("'one', which has been stubbed with '1'.", entry.message)
    assert_equal([], entry.details)
    assert_equal('SomeService', entry.title)
  end

end
