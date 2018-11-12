module KnockKnock
  class Client
    def initialize(
      counter = KnockKnock::Counter::InMemory.new,
      evictor = KnockKnock::Evictor::InMemory.new,
      max_requests = KnockKnock.max_requests,
      time_range = KnockKnock.time_range
    )
      @counter = counter
      @evictor = evictor
      @max_requests = max_requests
      @time_range = time_range
    end

    def allow?(ip)
      below = counter.put_if_below(ip, max_requests)

      evictor.mark(ip, Time.now) if below

      below
    end

    private

    attr_reader :counter, :evictor, :max_requests, :time_range
  end
end
