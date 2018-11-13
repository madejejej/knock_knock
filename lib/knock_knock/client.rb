module KnockKnock
  class Client
    attr_reader :counter, :evictor

    def initialize(counter, evictor)
      @counter = counter
      @evictor = evictor
    end

    def allow?(request_metadata)
      below_limit = if evictor.overloaded?
                      counter.below_limit?(request_metadata.ip)
                    else
                      below = counter.put_if_below_limit(request_metadata.ip)

                      evictor.mark!(request_metadata) if below

                      below
                    end

      KnockKnock.logger.debug("#{request_metadata.ip} below limit?: #{below_limit}")
      KnockKnock.logger.info("#{request_metadata.ip} blocked") if !below_limit

      below_limit
    end

    # Stops any background threads. Call this if you no longer intend to use the Client
    def teardown
      evictor.teardown
    end
  end
end
