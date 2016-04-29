# Adalog

It pairs some Log-like Repository implementation with a Sinatra app. What an achievement, right? No? I agree, but read on.


## Motivation

Far, far too many third party services do not bother to implement competent sandbox environments. If you're doing "the right thing" and wrapping their client libraries in your own adapter layer (of some variety), you can easily swap out for a stub implementation in development, test or staging environments.

Great! But now you have to write a second set test of adapaters yourself. So... not great! And sometimes all you want to do is check they were even sending (or receiving) the right message/data anyway?

In the way that Matz "is not a concurrency guy", I "am not a logging guy". If I'm poking around in a UI while developing, I don't want to cram even more into my logs just to make sure an API call with big chunk of JSON got sent off properly, amidst 30 render statements, 3 or 4 SQL queries, and probably some stuff going in to/out of Redis.

In fact, since I'm already building a webpage, why can't I see it in my browser?

Enter <strong>Log</strong>ging for Stub <strong>Ada</strong>pters: Adalog


## We _Can_ Have Nice Things

Adalog really only needs one thing: A repository to put entries into and take them out of. For this purpose, a repository (repo for short) is anything that responds to four messages: `fetch`, `insert`, `clear!`, and `all`.

Adalog even comes with three available repos: `InMemoryRepo`, `PStoreRepo` and `ActiveRecordRepo` which all do exactly what their names suggest.

The Sinatra app has (for now) a single page that lists the output of `Adalog.configuration.repo.all` in reverse chronological order. Ideal for running as its own little service or mounting in a Rails app during in the development environment!

## Example Configuration and Usage

After the usual addition of `gem 'adalog'` to your `Gemfile` and `bundle install` usage can be achieved by the following:

```ruby
Adalog.configure do |config|
  # No action needed, however the default repo is a non-threadsafe InMemoryRepo
end

# Insert something that has a 'title', optionally a 'message' and 'details'
Adalog.configuration.repo.insert(
  title:    "StubSendGridAdapter",
  message:  "Email Sent")
```

With only one repo in use, Adalog will forward the messages of `insert`, `fetch`, `clear!` and `all` to that one repo. Like so:

```ruby
Adalog.insert(
  title:    "StubSendGridAdapter",
  message:  "Email Sent"
  details: {
    to:       "foo@example.com",
    from:     "bar@example.com",
    template: "welcome-email"
  })
```

The default repos also accept entries with a `timestamp`, which defaults to `Time.now` and a `format` of the `details` attribute to assist in displaying in the Sinatra app's view. The `format` defaults to `'json'`.

Speaking of the app, it can be executed in the usual manner of creating a `config.ru` file:

```ruby
require 'adalog'
run Adalog::Web
```

followed by `rackup` in a terminal. Or, within a Rails app, it can be mounted via `routes.rb` at a particular path:

```ruby
YourApp::Application.routes.draw do

  unless Rails.env.production?
    mount Adalog::Web => '/adalog'
  end

end
```

Visit the particular URL for the Sinatra standalone or Rails route, and _voilà!_


## Configuration Options

Actually, that _"voilà!"_ might have been a little underwhelming. The default `InMemoryRepo` is blank upon each boot (it is in-memory, after all) so the default configuration won't show anything initially. Specifying a different repository will fix that. It is one configuration option among the following:

- **repo:** The repository to store and retreive from. Defaults to `Adalog::InMemoryRepo`.
- **singleton:** Whether or not to add class methods to the root `Adalog` module to access a singular repo. Defaults to `true`.
- **time_format:** the `strftime` format string to use when displaying dates in the app's views. Defaults to `"%H:%M:%S - %d %b %Y"`.
- **web_heading:** the title of the heading in the app's views.
- **erb_layout:** _(not yet implemented)_ set the layout for the app's views.
- **views_folder:** _(not yet implemented)_ specify a custom views folder for the Sinatra app if you feel like rolling your own entirely new version of the front-end.

As an example, here is a configuration that uses a threadsafe PStore to persist the log entries, changes the time formatting, and sets a custom heading:

```ruby
Adalog.configure do |config|
  pstore_file         = "log/adalog-#{ENV['RACK_ENV']}.pstore"
  config.repo         = Adalog::PStoreAdapter.new(pstore_file)
  config.time_format  = "%b %d %H:%M:%S"
  config.web_heading  = "Poor Richard's Third Party API Calls"
end
```

And now if, in the course of building out your application, you can make an adapter which simply calls out to `Adalog.insert` with its data rather than a non-sandboxed third-party service, and you can validate "success" (insofar as your local code succeeded) by visiting a web page instead of checking a logfile!


## Included Adapters

Much like how useful repositories come built-in, there are also basic adapters included in the project. Presently the only included adapter that saves you from writing your own, is `SimpleLoggingAdapter`, which uses `method_missing` to write entries for every method call made on it. For example:

```ruby
# After configuring Adalog
adapter = Adalog::SimpleLoggingAdapter.new("StubMoosendAdapter", Adalog.repo)
adapter.unsubscribe_email('baz@example.com')
```

And now `Adalog.repo` contains the entry:
```ruby
{ title:      "StubMoosendAdapter",
  timestamp:  "...",
  message:    "unsubscribe_email",
  details:    "['baz@example.com']",
  format:     "json"
}
```

Although one would obviously want to use a more dependency-injection-esque style when choosing `Adalog::SimpleLoggingAdapter` over whatever the production-mode default adapter is for the service in question.

## Project Status and Goals

This project adheres to [Semantic Versioning](http://semver.org/), including the part whereby being pre-1.0 means that all bets are off, code can and will change radically, and that it should not be considered "production-ready" until said time as version `1.0.0` is declared.

This library is being test-driven by its inclusion within a functioning production application, so rest assured it will get there soon enough. In the mean time, feedback is welcome. Bug reports about functionality that the README claims works but doesn't is welcome. But so as not to distract from the original goals, contributions in the form of pull requests will languish until the project's initial functionality is completed.


### Remaining Work Prior to 1.0.0

- Customization of ERB Layout.
- Customization of Sinatra Layout.
- Time formats that allow for strictly numeric time or even string-based logical time.
- A quick script to color-code entries with the same title.
- Implementations for `InMemoryRepo#fetch` and `PStoreRepo#fetch`.
- Tests for the three built-in repository classes.
- A `StubLoggingAdapter` which can be pre-programmed with responses to certain messages.
- A `MockLoggingAdapter` which can be pre-programmed with responses to certain messages and asked to enforce that some messages were received.
- A method (working name `MultiWeb`) to allow multiple Sinatra apps to be generated, in case one wants to have a separate route-and-repo combination for every adapter.

