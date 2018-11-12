module KnockKnock
  class Client
    def initialize(counter, evictor)
      @counter = counter
      @evictor = evictor
    end

    def allow?(ip)
      if evictor.overloaded?
        counter.below_limit?(ip)
      else
        below = counter.put_if_below_limit(ip)

        evictor.mark!(ip, Time.now) if below

        below
      end
    end

    private

    attr_reader :counter, :evictor
  end
end
