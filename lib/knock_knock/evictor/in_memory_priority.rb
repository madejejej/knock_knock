require_relative 'queue/thread_safe_priority_queue'

module KnockKnock
  module Evictor
    # This Evictor should be used when you don't expect that your requests come in increasing
    # timestamp order.
    class InMemoryPriority
      QUEUE_OVERLOAD_FRACTION = 0.9

      attr_reader :evicting_thread

      def initialize(ttl, max_queue_size, counter)
        @ttl = ttl
        @counter = counter
        @queue = Queue::ThreadSafePriorityQueue.new(max_size: max_queue_size)
        @max_queue_size = max_queue_size
        @lock = Mutex.new
        @evicting_thread = start_evicting_thread
      end

      # Puts request_metadata into @queue so that the evicting thread
      # will decrement the counter after TTL.
      def mark!(request_metadata)
        queue << request_metadata
      end

      # Stops the running evicting thread.
      # TODO: terminate gracefully
      def teardown
        evicting_thread.kill
      end

      # A simple heuristic that returns true if the queue is overloaded.
      # An alternative might be to check if the evictor queue is full,
      # but that'd need a full synchronisation.
      # Thread A might first check that the queue is not full, but in the meantime other threads
      # could make it full. Then, Thread A would block.
      def overloaded?
        queue.size / max_queue_size > QUEUE_OVERLOAD_FRACTION
      end

      private

      attr_reader :ttl, :counter, :queue, :max_queue_size, :lock

      def start_evicting_thread
        Thread.new do
          while true
            request_metadata = queue.try_pop_if_ttl_passed(ttl, Time.now)

            next if request_metadata.nil?

            ip = request_metadata.ip

            KnockKnock.logger.debug("Evicting IP #{ip}")

            counter.decrement(ip)
          end
        end
      end
    end
  end
end
