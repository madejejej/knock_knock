require 'thread'

module KnockKnock
  module Counter
    class InMemory
      def initialize(limit)
        @hash = {}
        @limit = limit
        @mutex = Mutex.new
      end

      def put_if_below(ip)
        # since we will be in a threaded environment, this whole method needs to be synchronized
        # we don't have any mechanisms that are able to execute this logic atomically
        current = mutex.synchronize do
          current = hash[ip].to_i
          hash[ip] = current + 1
        end

        current <= limit
      end

      private

      attr_reader :hash, :limit, :mutex
    end
  end
end
