RSpec.describe KnockKnock do
  it 'has a version number' do
    expect(KnockKnock::VERSION).not_to be nil
  end

  it 'can create client' do
    client = KnockKnock.create_client

    expect(client).to be_a KnockKnock::Client

    client.teardown
  end
end
