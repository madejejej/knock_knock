module KnockKnock
  class Client
    def initialize(
      counter = KnockKnock.counter,
      evictor = KnockKnock.evictor
    )
      @counter = counter
      @evictor = evictor
    end

    def allow?(ip)
      below = counter.put_if_below(ip)

      evictor.mark(ip, Time.now) if below

      below
    end

    private

    attr_reader :counter, :evictor
  end
end
