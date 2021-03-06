RSpec.describe KnockKnock::Counter::InMemory do
  let(:limit) { 4 }

  subject(:counter) { described_class.new(limit) }

  describe '#put_if_below_limit' do
    let(:ip) { '68.52.55.12' }

    it 'returns true if the IP is not yet recorded' do
      expect(subject.put_if_below_limit(ip)).to eq true
    end

    it 'returns true if the IP is already recorded but far to the limit' do
      expect(subject.put_if_below_limit(ip)).to eq true
      expect(subject.put_if_below_limit(ip)).to eq true
    end

    it 'returns true if the IP reaches the limit' do
      limit.times do
        expect(subject.put_if_below_limit(ip)).to eq true
      end
    end

    it 'returns false after exceeding the limit for the first time' do
      limit.times do
        expect(subject.put_if_below_limit(ip)).to eq true
      end

      expect(subject.put_if_below_limit(ip)).to eq false
    end

    it 'returns false after exceeding the limit multiple times' do
      limit.times do
        expect(subject.put_if_below_limit(ip)).to eq true
      end

      5.times { expect(subject.put_if_below_limit(ip)).to eq false }
    end

    it 'does not increment the counter after exceeding the limit' do
      limit.times do
        expect(subject.put_if_below_limit(ip)).to eq true
      end

      5.times do
        subject.put_if_below_limit(ip)
        expect(subject.instance_variable_get(:@hash)[ip]).to eq limit
      end
    end
  end
end
