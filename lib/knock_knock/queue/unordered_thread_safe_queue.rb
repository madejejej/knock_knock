module KnockKnock
  module Queue
    # This class implements an Unordered Queue which is thread-safe. Use this if you intend
    # to use this gem with requests that are ordered in time. Otherwise, the Evictor might not
    # be able to correctly clean up stale requests, leading to blocking IPs that should
    # no longer be blocked.
    class UnorderedThreadSafeQueue
      def initialize(max_size:)
        @queue = SizedQueue.new(max_size)
      end

      def <<(elem)
        queue << elem
      end

      def pop
        queue.pop
      end

      private

      attr_reader :queue
    end
  end
end
