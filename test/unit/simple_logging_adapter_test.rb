require 'test_helper'

class SimpleLoggingAdapterTest < Minitest::Test

  def setup
    @default_repo = Adalog::InMemoryRepo.new
  end


  def default_repo
    @default_repo ||= Adalog::InMemoryRepo.new
  end


################################################################################


  test "new creates a logging adapter class" do
    adapter_class = Adalog::SimpleLoggingAdapter.new('SomeService', default_repo)
    assert_kind_of(Class, adapter_class)
  end


  test "class accessors for service_name and repo" do
    adapter_class = Adalog::SimpleLoggingAdapter.new('SomeService', default_repo)
    assert_respond_to(adapter_class, :service_name)
    assert_respond_to(adapter_class, :repo)
    adapter = adapter_class.new
    assert_equal('SomeService', adapter.service_name)
    assert_equal(default_repo, adapter.repo)
  end


  test "all messages sent are stored as entries with message as message attribute" do
    adapter_class = Adalog::SimpleLoggingAdapter.new('SomeService', default_repo)
    adapter       = adapter_class.new
    adapter.some
    adapter.call
    adapter.method_names("with", :arguments)
    repo_contents = default_repo.all
    assert(!!repo_contents.find { |entry| :some == entry.message })
    assert(!!repo_contents.find { |entry| :call == entry.message })
    assert(!!repo_contents.find { |entry| :method_names == entry.message })
  end


  test "message arguments are stored in the details section of an entry" do
    adapter_class = Adalog::SimpleLoggingAdapter.new('OtherServiceName', default_repo)
    adapter       = adapter_class.new
    adapter.capture_a_method_name("with", :arguments)
    entry = default_repo.all.first
    assert(!!entry)
    assert_equal(["with", :arguments], entry.details)
  end


  test "the service name is used as the entry title" do
    adapter_class = Adalog::SimpleLoggingAdapter.new('OtherServiceName', default_repo)
    adapter       = adapter_class.new
    adapter.capture_a_method_name("with", :arguments)
    entry = default_repo.all.first
    assert(!!entry)
    assert_equal('OtherServiceName', entry.title)
  end

end
