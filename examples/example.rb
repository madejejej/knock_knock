require 'knock_knock'

def create_thread(client, requests_per_second, seconds_alive, ip)
  Thread.new do
    seconds_alive.times do
      requests_per_second.times do
        client.allow?(KnockKnock::RequestMetadata.new(ip, Time.now))
      end

      sleep 1
    end
  end
end

KnockKnock.configure do |config|
  config.max_requests = 100
  config.time_range = 10
  config.logger = Logger.new($stdout, level: Logger::Severity::INFO)
end

client = KnockKnock.create_client

puts 'Limits: 100 requests / 10 seconds'

puts 'doing a small number of requests from a few 128.0.0.0/32 IPs, those should not be blocked'
bg_threads = [
  create_thread(client, 1, 40, '128.1.1.1'),
  create_thread(client, 1, 40, '128.200.1.1'),
  create_thread(client, 1, 40, '128.128.1.1'),
  create_thread(client, 1, 40, '128.128.255.1'),
  create_thread(client, 1, 40, '128.128.255.50')
]


puts 'crossing the limits politely - will make 110 requests in 10 seconds'

thread1 = create_thread(client, 3, 10, '1.1.1.1')
thread2 = create_thread(client, 3, 10, '1.1.1.1')
thread3 = create_thread(client, 3, 10, '1.1.1.1')
thread4 = create_thread(client, 2, 10, '1.1.1.1')

[thread1, thread2, thread3, thread4].each(&:join)

puts 'DONE'
sleep 3
puts 'the same with more threads'

11.times.map do
  create_thread(client, 1, 10, '2.2.2.2')
end.each(&:join)

puts 'DONE'
sleep 3
puts 'aggressive attackers: 120 requests in split-second'

12.times.map do
  create_thread(client, 10, 1, '3.3.3.3')
end.each(&:join)

puts 'DONE'
puts 'waiting 10 seconds, IP 3.3.3.3 should no longer be blocked'
sleep 10

puts '110 requests from IP 3.3.3.3:'

11.times.map do
  create_thread(client, 10, 1, '3.3.3.3')
end.each(&:join)

sleep 5

puts 'IPs 1.1.1.1 and 2.2.2.2 should also not be blocked, doing 101 requests from each'
thread1 = create_thread(client, 101, 1, '1.1.1.1')
thread2 = create_thread(client, 101, 1, '2.2.2.2')

thread1.join
thread2.join

puts 'DONE'

puts 'waiting for bg threads to stop.'
bg_threads.each(&:join)

client.teardown
