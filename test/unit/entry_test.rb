require 'test_helper'

class EntryTest < Minitest::Test

  ##
  # So we can be lazy and omit typing the namspace fifty times.
  Entry = Adalog::Entry


  AnotherEntryClass = Struct.new(:title, :timestamp, :message, :details)


  class AnotherEntryClassWithToH
    attr_reader :to_h_was_used

    def initialize(timestamp)
      @timestamp      = timestamp
      @to_h_was_used  = false
    end

    def to_h
      @to_h_was_used = true
      { title:      "Something",
        timestamp:  @timestamp,
        message:    "happened",
        details:    "in the world"
      }
    end
  end


################################################################################


  test "is invalid when none of title, message or details are set" do
    entry = Entry.new
    refute(entry.valid?)
    assert(entry.errors.any?)
  end


  test "will provide the current timestamp if no timestamp is given" do
    before_new  = Time.now
    entry       = Entry.new
    after_new   = Time.now
    assert(before_new <= entry.timestamp)
    assert(entry.timestamp <= after_new)
  end


  test "is valid with at least one of title, message or details" do
    entry = Entry.new(title: "GroupRaise Schedule Adapter")
    assert(entry.valid?)
    entry = Entry.new(message: "meal:requested")
    assert(entry.valid?)
    entry = Entry.new(details: "EMERGE Fellowship at Berry Hill")
    assert(entry.valid?)
  end


  test "can be built from another object of the same interface" do
    another_obj = AnotherEntryClass.new("Something", Time.now, "happened", "in the world")
    entry       = Entry.build(another_obj)
    assert(entry.valid?)
    assert_equal(another_obj.title,     entry.title)
    assert_equal(another_obj.timestamp, entry.timestamp)
    assert_equal(another_obj.message,   entry.message)
    assert_equal(another_obj.details,   entry.details)
  end


  test "is invalid when built from an object missing the required methods" do
    entry = Entry.build(Object.new)
    refute(entry.valid?)
  end


  test "can be built from a hash-like object" do
    hash  = {
      title:      "Something",
      timestamp:  Time.now,
      message:    "happened",
      details:    "in the world"
    }
    entry = Entry.build(hash)
    assert(entry.valid?)
    assert_equal(hash[:title],      entry.title)
    assert_equal(hash[:timestamp],  entry.timestamp)
    assert_equal(hash[:message],    entry.message)
    assert_equal(hash[:details],    entry.details)
  end


  test "can be built from a hash-like object with string keys" do
    hash  = {
      'title'     => "Something",
      'timestamp' => Time.now,
      'message'   => "happened",
      'details'   => "in the world"
    }
    entry = Entry.build(hash)
    assert(entry.valid?)
    assert_equal(hash['title'],     entry.title)
    assert_equal(hash['timestamp'], entry.timestamp)
    assert_equal(hash['message'],   entry.message)
    assert_equal(hash['details'],   entry.details)
  end


  test "can be built from an object responding to to_h" do
    now   = Time.now
    other = AnotherEntryClassWithToH.new(now)
    entry = Entry.build(other)
    assert(other.to_h_was_used)
    assert(entry.valid?)
    assert_equal("Something",     entry.title)
    assert_equal(now,             entry.timestamp)
    assert_equal("happened",      entry.message)
    assert_equal("in the world",  entry.details)
  end


  test "can be built from distinct keyword arguments" do
    now   = Time.now
    entry = Entry.new(
      timestamp:  now,
      title:      "Something",
      message:    "happened",
      details:    "in the world")
    assert(entry.valid?)
    assert_equal("Something",     entry.title)
    assert_equal(now,             entry.timestamp)
    assert_equal("happened",      entry.message)
    assert_equal("in the world",  entry.details)
  end

end
