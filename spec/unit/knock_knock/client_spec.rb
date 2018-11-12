RSpec.describe KnockKnock::Client do
  let(:counter) { instance_double(KnockKnock::Counter::InMemory) }
  let(:evictor) { instance_double(KnockKnock::Evictor::InMemory) }
  let(:max_requests) { 10 }
  let(:time_range) { 60 }

  subject(:client) { described_class.new(counter, evictor, max_requests, time_range) }

  describe '#allow?' do
    let(:ip) { '45.82.21.35' }
    let(:now) { Time.parse('2018-08-08 15:00') }

    subject { client.allow?(ip) }

    context 'when the client didnt exceed the limit' do
      it 'returns true' do
        expect(counter).to receive(:put_if_below).with(ip, max_requests).and_return true
        expect(evictor).to receive(:mark).with(ip, now)

        Timecop.freeze(now) do
          expect(subject).to eq true
        end
      end
    end

    context 'when the client exceeded the limit' do
      it 'returns false' do
        expect(counter).to receive(:put_if_below).with(ip, max_requests).and_return false
        expect(evictor).not_to receive(:mark)

        expect(subject).to eq false
      end
    end
  end
end
