module KnockKnock
  class Client
    def initialize(counter, evictor)
      @counter = counter
      @evictor = evictor
    end

    def allow?(ip)
      below_limit = if evictor.overloaded?
                      counter.below_limit?(ip)
                    else
                      below = counter.put_if_below_limit(ip)

                      evictor.mark!(ip, Time.now) if below

                      below
                    end

      KnockKnock.logger.debug("#{ip} below limit?: #{below_limit}")
      KnockKnock.logger.info("#{ip} blocked") if !below_limit

      below_limit
    end

    # Stops any background threads. Call this if you no longer intend to use the Client
    def teardown
      evictor.teardown
    end

    private

    attr_reader :counter, :evictor
  end
end
