require 'dry-configurable'

require 'knock_knock/client'
require 'knock_knock/counter/in_memory'
require 'knock_knock/evictor/in_memory'
require 'knock_knock/evictor/in_memory_priority'
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

  # If set to false, will assume that requests don't come in increasing order of timestamps.
  # Will use a Priority-Queue based algorithm that may be more CPU-intensive.
  setting :ordered_timestamps, true

  setting :logger, Logger.new($stdout)


  class << self
    # Factory method that returns a KnockKnock::Client
    # It returns a new instance every time.
    # TODO: configurable Counter and Evictor
    def create_client
      counter = KnockKnock::Counter::InMemory.new(config.max_requests)

      evictor = create_evictor(counter)

      KnockKnock::Client.new(counter, evictor)
    end

    def logger
      config.logger
    end

    private

    def create_evictor(counter)
      if config.ordered_timestamps
        KnockKnock::Evictor::InMemory.new(
          config.time_range,
          config.max_queue_size,
          counter
        )
      else
        KnockKnock::Evictor::InMemoryPriority.new(
          config.time_range,
          config.max_queue_size,
          counter
        )
      end
    end
  end
end

