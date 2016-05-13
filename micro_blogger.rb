require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client
  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end
  
  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "Enter command (c for command list):"
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then shorten(parts[1])
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        when 'c' then command_list
        else
          puts "Command unknown: #{command}"
      end
    end
  end
  
  def tweet (message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Cannot post tweets longer than 140 characters."
    end
  end
  
  def dm (target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.map { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "@#{target} #{message}"
      tweet(message)
    else
      puts "You can't send DMs to someone who isn't your follower!"
    end
  end
  
  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    return screen_names
  end
  
  def spam_my_followers (message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end
  
  def everyones_last_tweet
    friends = @client.friends.map { |friend| @client.user(friend).screen_name }
    friends.sort_by! { |friend| friend.downcase }
    friends.each do |friend|
      status = @client.user(friend).status
      date = @client.user(friend).created_at.strftime("%A, %b %d")
      puts "#{friend} said this on #{date}..."
      puts status.text
      puts
    end
  end
  
  def shorten (orig_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{orig_url}"
    puts bitly.shorten(orig_url).short_url
    return bitly.shorten(orig_url).short_url
  end
  
  def command_list
    puts "Command list:"
    puts "t [message]          - tweet [message]"
    puts "dm [user] [message]  - send direct message to [user]"
    puts "spam [message]       - tweet [message] to all friends"
    puts "elt                  - display your friends' last tweets"
    puts "s [url]              - shorten [url] with Bit.ly"
    puts "turl [message] [url] - tweet [message] with [url] shortened with Bit.ly"
    puts "c                    - diplay command list"
    puts "q                    - quit"
  end
end

blogger = MicroBlogger.new
blogger.run
