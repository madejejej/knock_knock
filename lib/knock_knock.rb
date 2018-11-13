require 'dry-configurable'

require 'knock_knock/client'
require 'knock_knock/counter/in_memory'
require 'knock_knock/evictor/in_memory'
require 'knock_knock/queue/thread_safe_priority_queue'
require 'knock_knock/queue/thread_safe_queue'
require 'knock_knock/request_metadata'
require 'knock_knock/version'

module KnockKnock
  extend Dry::Configurable

  # maximum number of requests after the IP will be rate-limited in `time_range` seconds window
  setting :max_requests, 100

  # number of seconds for the rate limiting window
  setting :time_range, 60

  # max Evictor queue size. If crossed, some requests will not be registered for their time windows.
  # prevents against DoS.
  setting :max_queue_size, 1_000_000

  setting :logger, Logger.new($stdout)

  # Factory method that returns a KnockKnock::Client
  # It returns a new instance every time.
  # TODO: configurable Counter and Evictor
  def self.create_client
    queue = KnockKnock::Queue::ThreadSafeQueue.new(max_size: config.max_queue_size)

    counter = KnockKnock::Counter::InMemory.new(KnockKnock.config.max_requests)

    evictor = KnockKnock::Evictor::InMemory.new(
      KnockKnock.config.time_range,
      counter,
      queue
    )

    KnockKnock::Client.new(counter, evictor)
  end

  def self.logger
    config.logger
  end
end
