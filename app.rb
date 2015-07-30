require 'sinatra'
require 'redis'
require 'rack/ssl'

class App < Sinatra::Base
  configure do
    if ENV['REDISCLOUD_URL']
      uri = URI.parse(ENV['REDISCLOUD_URL'])
      $redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    else
      $redis = Redis.new
    end
  end

  get '/*' do
    content_type 'text/html'
    bootstrap_index(params[:index_key])
  end

  private

  def bootstrap_index(index_key)
    response = ''

    begin
      index_key &&= "#{ENV['APP_NAME']}:#{index_key}"
      index_key ||= $redis.get("#{ENV['APP_NAME']}:current")
      response = $redis.get(index_key)
    rescue Redis::BaseConnectionError => e
      puts e.message
      response = nil
    rescue SocketError => e
      puts e.message
      response = nil
    end

    response
  end
end
