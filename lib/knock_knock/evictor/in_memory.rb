module KnockKnock
  module Evictor
    class InMemory
      QUEUE_OVERLOAD_FRACTION = 0.9

      attr_reader :evicting_thread

      def initialize(ttl, max_queue_size, counter)
        @ttl = ttl
        @counter = counter
        @queue = SizedQueue.new(max_queue_size)
        @evicting_thread = start_evicting_thread
      end

      # puts ip and time into @queue so that the evicting thread
      # will decrement the counter after TTL.
      # The queue can get full when there are a lot of requests or the TTL are long.
      # Client should be aware of it and depending on the use-case, block the thread,
      # or don't push into the queue.
      def mark!(ip, time)
        queue << [ip, time + ttl]
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
        queue.size / queue.max > QUEUE_OVERLOAD_FRACTION
      end

      private

      attr_reader :ttl, :counter, :queue

      def start_evicting_thread
        Thread.new do
          while true
            ip, evict_at = queue.pop

            while evict_at > Time.now
              sleep evict_at - Time.now
            end

            counter.decrement(ip)
          end
        end
      end
    end
  end
end
