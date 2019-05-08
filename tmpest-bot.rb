require 'discordrb'

# Emojis
CROSS_MARK = "\u274c"

ROLL_DESCRIPTION = 'Rolls a number between 1 and 100 or 1 and a MAX value provided'
ROLL_USAGE = 'roll [max]'

ROLL_ALL_DESCRIPTION = 'Rolls a number between 1 and 100 or 1 and a MAX value provided for everyone in the same voice chat or channel of the caller'
ROLL_ALL_USAGE = 'rollall [max]'

DICE_DESCRIPTION = 'Simulates rolling dice N, M sided dice or 1 d6 by default'
DICE_USAGE = 'dice [NdM]'

FLIP_DESCRIPTION = 'Flips a coin'
FLIP_USAGE = 'flip'

DONE_DESCRIPTION = 'Just cause'
DONE_USAGE = 'done [mid]'


def add_dismissal(bot, message)
  message.react(CROSS_MARK)
  bot.add_await(:"dismiss_message_#{message.id}", Discordrb::Events::ReactionAddEvent, emoji: CROSS_MARK) do |reaction_event|
    next true unless reaction_event.message.id == message.id

    # Delete the matching message.
    message.delete
  end
  nil
end

#Psuedo Random Number Generator
prng = Random.new

bot = Discordrb::Commands::CommandBot.new(token: ENV['TMPEST_BOT_DISCORD_TOKEN'], prefix: '!', ignore_bots: true)

bot.command(:roll, min_args: 0, max_args: 1, description: ROLL_DESCRIPTION, usage: ROLL_USAGE) do |event, max=100|
  event.message.delete
  next "Can't roll the value provided: #{max}, try a number like 10" unless max.is_a? Integer
  message = event.respond "#{event.message.author.username} rolled #{prng.rand(max) + 1} out of #{max}"
  add_dismissal(bot, message)
end

bot.command(:rollall, min_arg: 0, max_args: 1, description: ROLL_ALL_DESCRIPTION, usage: ROLL_ALL_USAGE) do |event, max=100|
  event.message.delete
  messages << "Rolling for all!"
  winner = {name: nil, max: -1}
  caller = event.user
  channels = event.server.channels

  voice_channels = channels.find_all { |channel| channel.type == 2 } # 2 is voice
  target_channel = voice_channels.find { |channel| channel.users.include?(caller) }

  if target_channel
    target_channel.users.each do |user|
      rand_val = prng.rand(max) + 1
      winner = {name: user.username, max: rand_val} if rand_val > winner[:max]
      messages << "#{user.username} rolled #{rand_val} (1-#{max})"
    end
  else
    online_users = event.server.online_members(include_bots: false)

    online_users.each do |user|
      rand_val = prng.rand(max) + 1
      winner = {name: user.username, max: rand_val} if rand_val > winner[:max]
      messages << "#{user.username} rolled #{rand_val} (1-#{max})"
    end
  end

  messages << "\n**#{winner[:name]} won with a roll of #{winner[:max]}!**"
  message = event.respond messages.join('\n')
  add_dismissal(bot, message)
end

bot.command(:dice, min_args: 0, max_args: 1, description: DICE_DESCRIPTION, usage: DICE_USAGE) do |event, roll='1d6'|
  event.message.delete
  times, sides = roll.split('d')
  rolls = []
  sum = 0
  (1..times.to_i).each do
    val = prng.rand(sides.to_i) + 1
    rolls << val
    sum += val
  end

  message = event.respond "Rolling #{times}, #{sides} sided dice\nRolls: #{rolls.join(', ')} | **Total: #{sum}**"
  add_dismissal(bot, message)
end

bot.command(:flip, min_args: 0, max_args: 0, description: FLIP_USAGE, usage: FLIP_USAGE) do |event|
  event.message.delete
  message = event.respond "#{prng.rand(2) == 1 ? 'Tails' : 'Heads'}"
  add_dismissal(bot, message)
end

bot.command(:mid, min_args: 0, max_args: 1, description: DONE_DESCRIPTION, usage: DONE_USAGE) do |event, mid="Mid"|
  event.message.delete
  message = event.respond "#{mid} is done..."
  add_dismissal(bot, message)
end

# TODO rc - readycheck
# Get users like rollall, print ready up message with emoji reactions "Check Mark", "Red X", and maybe "Clock" (need a few min)
# After X time, delete and state summary

bot.run(false)
