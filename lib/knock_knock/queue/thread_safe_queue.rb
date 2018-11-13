module KnockKnock
  module Queue
    # This class implements an Unordered Queue which is thread-safe. Use this if you intend
    # to use this gem with requests that are ordered in time. Otherwise, the Evictor might not
    # be able to correctly clean up stale requests, leading to blocking IPs that should
    # no longer be blocked.
    class ThreadSafeQueue
      def initialize(max_size:)
        @queue = SizedQueue.new(max_size)
      end

      def <<(request_metadata)
        queue << request_metadata
      end

      def try_pop_if_ttl_passed(ttl, time)
        request_metadata = queue.pop

        evict_at = [request_metadata.timestamp + ttl, time].max

        if evict_at > time
          sleep_time = evict_at - time

          sleep sleep_time
        end

        request_metadata
      end

      def size
        queue.size
      end

      def max
        queue.max
      end

      private

      attr_reader :queue
    end
  end
end
