RSpec.describe KnockKnock::Evictor::InMemory do
  let(:ttl) { 2 }
  let(:counter) { instance_double(KnockKnock::Counter::InMemory) }
  let(:queue) { KnockKnock::Queue::ThreadSafeQueue.new(max_size: 100) }

  subject(:evictor) { described_class.new(ttl, counter, queue) }

  after do
    evictor.teardown
    Timecop.return
  end

  describe '#mark!' do
    let(:now) { Time.parse('2018-08-08 15:00:00') }
    let(:ip) { '52.44.12.123' }
    let(:request_metadata) { KnockKnock::RequestMetadata.new(ip, now) }
    let(:ip2) { '52.88.12.123' }
    let(:ip3) { '44.12.122.58' }

    it 'doesnt decrement the counter if TTL has not passed' do
      expect(counter).not_to receive(:decrement)

      Timecop.freeze(now)

      subject.mark!(request_metadata)

      sleep 0.2
    end

    it 'decrements the counter after TTL' do
      Timecop.freeze(now)

      subject.mark!(request_metadata)

      sleep 0.2

      expect(counter).to receive(:decrement).with(ip)

      Timecop.travel(now + ttl)
      subject.evicting_thread.run

      sleep 0.3 # allow some time for the thread to work
    end

    it 'works in a loop' do
      Timecop.freeze(now)

      subject.mark!(request_metadata)
      subject.mark!(KnockKnock::RequestMetadata.new(ip2, now + 5))
      subject.mark!(KnockKnock::RequestMetadata.new(ip3, now + 10))

      sleep 0.2

      expect(counter).to receive(:decrement).with(ip)

      Timecop.travel(now + ttl)
      subject.evicting_thread.run

      sleep 0.3

      expect(counter).to receive(:decrement).with(ip2)
      Timecop.travel(now + 5 + ttl)
      subject.evicting_thread.run

      sleep 0.3

      expect(counter).to receive(:decrement).with(ip3)
      Timecop.travel(now + 10 + ttl)
      subject.evicting_thread.run

      sleep 0.3
    end
  end
end
