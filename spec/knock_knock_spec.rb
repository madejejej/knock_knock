RSpec.describe KnockKnock do
  it 'has a version number' do
    expect(KnockKnock::VERSION).not_to be nil
  end

  it 'can create client if using ordered timestamps' do
    KnockKnock.configure do |config|
      config.ordered_timestamps = true
    end

    client = KnockKnock.create_client

    expect(client).to be_a KnockKnock::Client
    expect(client.evictor).to be_a KnockKnock::Evictor::InMemory

    client.teardown
  end

  it 'can create client if using unordered timestamps' do
    KnockKnock.configure do |config|
      config.ordered_timestamps = false
    end

    client = KnockKnock.create_client

    expect(client).to be_a KnockKnock::Client
    expect(client.evictor).to be_a KnockKnock::Evictor::InMemoryPriority

    client.teardown
  end
end
