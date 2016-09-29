require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'facebook/messenger'

puts "VERIFY_TOKEN: #{ENV['VERIFY_TOKEN']}"

Facebook::Messenger.configure do |config|
  config.access_token = ENV['ACCESS_TOKEN']
  config.verify_token = ENV['VERIFY_TOKEN']
end

include Facebook::Messenger

client = BotMetrics::Client.new(api_key: ENV['BOTMETRICS_API_KEY'],
                                bot_id: ENV['BOTMETRICS_BOT_ID'],
                                api_host: ENV['BOTMETRICS_API_HOST'])

Bot.on :message do |message|
  puts "Received '#{message.inspect}' from #{message.sender}"
  raw_entry = message.messaging
  result = client.track({'entry' => [{'messaging' => raw_entry}]})
  puts "result: #{result}"

  if raw_entry['message'] && !raw_entry['message']['is_echo']
    case message.text
    when /hello/i
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: 'Hello, human!',
          quick_replies: [
            {
              content_type: 'text',
              title: 'Hello, bot!',
              payload: 'HELLO_BOT'
            }
          ]
        }
      )
    when /something humans like/i
      Bot.deliver(
        recipient: message.sender,
        message: {
          text: 'I found something humans seem to like:'
        }
      )
    end
  end
end
