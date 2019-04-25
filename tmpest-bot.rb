require 'discordrb'

#Psuedo Random Number Generator
prng = Random.new

#TODO move token to ENV
bot = Discordrb::Bot.new(token: ENV['TMPEST_BOT_DISCORD_TOKEN'])

message = "Rolling for all!\n"
max = {name: nil, max: -1}

bot.message(with_text: '/roll') do |event|
  event.respond "#{event.message.author.username} rolled #{prng.rand(100)} out of 100"
end

bot.message(with_text: '/rollall') do |event|
  caller = event.user
  channels = event.server.channels

  voice_channels = channels.find_all { |channel| channel.type == 2 } # 2 is voice
  target_channel = voice_channels.find { |channel| channel.users.include?(caller) }

  if target_channel
    target_channel.users.each do |user|
      rand_val = prng.rand(100)
      max = {name: user.username, max: rand_val} if rand_val > max[:max]
      message << "#{user.username} rolled #{rand_val} (1-100)\n"
    end
  else
    online_users = event.server.online_members(include_bots: false)

    online_users.each do |user|
      rand_val = prng.rand(100)
      max = {name: user.username, max: rand_val} if rand_val > max[:max]
      message << "#{user.username} rolled #{rand_val} (1-100)\n"
    end
  end

  message << "\n#{max[:name]} won with a roll of #{max[:max]}!"

  event.respond message
end

#TODO /rc

bot.run(true)
