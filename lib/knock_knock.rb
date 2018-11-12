require 'dry-configurable'

require 'knock_knock/client'
require 'knock_knock/counter/in_memory'
require 'knock_knock/evictor/in_memory'
require 'knock_knock/version'

module KnockKnock
  extend Dry::Configurable

  # maximum number of requests after the IP will be rate-limited in `time_range` seconds window
  setting :max_requests, 100

  # number of seconds for the rate limiting window
  setting :time_range, 60

  # factory method for a Counter instance
  # TODO: make it configurable
  def self.counter
    KnockKnock::Counter::InMemory.new(KnockKnock.config.max_requests)
  end

  # factory method for an Evictor instance
  # TODO: make it configurable
  def self.evictor
    KnockKnock::Evictor::InMemory.new(KnockKnock.config.time_range)
  end
end
