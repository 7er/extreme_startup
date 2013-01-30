require 'rubygems'
require 'sinatra'
require 'mathn'


def filter_primes(candidates)
  result = []
  candidates.each do |candidate|
    Prime.each do |prime|
      if prime == candidate
        result << candidate
        break
      elsif candidate < prime
        break
      end
    end
  end
  result
end


class ExtremeStartup
  def initialize
    @last_name = nil
  end
  
  def answer(q)
    case q
    when /the sum of (\d+) and (\d+)/
      ($1.to_i + $2.to_i).to_s
    when /vil-du/
      "ja"
    end
  end
end

server = ExtremeStartup.new

configure do
  set :port, 1337
end

get '/' do
  puts "A request has arrived: '#{params[:q]}'"
  
  answer = server.answer(params[:q])
  puts "we answered: #{answer}"
  answer
end
