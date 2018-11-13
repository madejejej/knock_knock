require 'priority_queue'

module KnockKnock
  module Queue
    # This class implements a thread-safe priority queue. If you cannot assume that your requests
    # are coming one after another, you have to use this queue
    # instead of `KnockKnock::Queue::ThreadSafeQueue`. Note that it has worse performance
    # characteristics. The pop operation is O(log n) and it requires synchronisation with a Lock.
    class ThreadSafePriorityQueue
      def initialize(max_size:)
        @queue = PriorityQueue.new
        @max_size = max_size
        @lock = Mutex.new
      end

      def <<(request_metadata)
        lock.synchronize do
          queue.push(request_metadata, request_metadata.timestamp)
        end
      end

      def try_pop_if_ttl_passed(ttl, time)
        sleep 0.1 while queue.empty?

        lock.synchronize do
          # I chose not to lock checking whether the queue is empty. Hence, we have to check
          # it again to make sure we don't attempt to remove item from an empty array.
          return if queue.empty?

          queue.delete_min_return_key if queue.min_priority + ttl <= time
        end
      end

      def size
        # TODO: we could allow multiple readers
        lock.synchronize do
          queue.length
        end
      end

      def max
        max_size
      end

      private

      attr_reader :queue, :max_size, :lock
    end
  end
end
