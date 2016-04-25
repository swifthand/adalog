require 'test_helper'

class ConfigurationTest < Minitest::Test

  class MockRepo
    def recorded_calls
      @recorded_calls ||= []
    end

    def method_missing(msg, *args, &block)
      recorded_calls << msg
      msg
    end

    def called?(msg)
      recorded_calls.include?(msg)
    end
  end


################################################################################


  test "can be configured via namespace configure method" do
    repo = MockRepo.new
    Adalog.configure do |config|
      config.repo         = repo
      config.singleton    = false
      config.html_erb     = true
      config.web_heading  = "Captain what's our heading?"
      config.time_format  = "%Y-%m-%d %H:%M:%S"
    end

    assert_equal(repo, Adalog.configuration.repo)
    assert_equal(false, Adalog.configuration.singleton)
    assert_equal(true,  Adalog.configuration.html_erb)
    assert_equal("Captain what's our heading?", Adalog.configuration.web_heading)
    assert_equal("%Y-%m-%d %H:%M:%S", Adalog.configuration.time_format)
  end


  test "repo can be accessed via namespace when singleton is true" do
    repo = MockRepo.new
    Adalog.configure do |config|
      config.repo         = repo
      config.singleton    = true
      config.html_erb     = true
      config.web_heading  = "Captain what's our heading?"
      config.time_format  = "%Y-%m-%d %H:%M:%S"
    end
    Adalog.fetch
    repo.called?(:fetch)
    Adalog.insert
    repo.called?(:insert)
    Adalog.all
    repo.called?(:all)
    Adalog.clear!
    repo.called?(:clear!)
  end


end
