# KnockKnock

- Knock, knock!
- Who's there?
- 40k requests from a single IP saying hello to your server.


## Running an example

After checking out this repository:

```bash
gem build knock_knock.gemspec
gem install --local knock_knock-0.1.0.gem
ruby examples/example.rb
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'knock_knock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knock_knock

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/knock_knock.
