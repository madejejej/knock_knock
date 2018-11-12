require 'thread'

module KnockKnock
  module Counter
    class InMemory
      def initialize(limit)
        @hash = {}
        @limit = limit
        @mutex = Mutex.new
      end

      # Increments the counter value for a given IP
      # returns whether ip is below the limit or not
      def put_if_below_limit(ip)
        # since we will be in a threaded environment, this whole method needs to be synchronized
        # we don't have any mechanisms that are able to execute this logic atomically
        current = mutex.synchronize do
          current = hash[ip].to_i

          # do not increment the counter if we're already over limit
          return false if current >= limit

          hash[ip] = current + 1
        end

        current <= limit
      end

      def below_limit?(ip)
        mutex.synchronize do
          hash[ip] < limit
        end
      end

      # Decrements the value of requests for a given IP
      # Assumes that the given IP is present in the underlying Hash
      def decrement(ip)
        mutex.synchronize do
          new_val = hash[ip] - 1

          if new_val <= 0
            hash.delete(ip)
          else
            hash[ip] -= 1
          end
        end
      end

      private

      attr_reader :hash, :limit, :mutex
    end
  end
end
