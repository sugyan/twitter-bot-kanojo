require 'json'

module Twitter
  class Twitter
    def initialize(username, password)
      @username = username
      @password = password
    end
  
    def update(body)
      url = 'http://twitter.com/statuses/update.json'
      request(url, 'POST', { :payload => "status=#{body}" })
    end
  
    def user_timeline(screen_name)
      url = "http://twitter.com/statuses/user_timeline/#{screen_name}.json"
      res = request(url)
      JSON.parser.new(res.body).parse
    end
  
    private
  
    def request(url, method = 'GET', options = {})
      req = Net::HTTP::Get.new('/')
      req.basic_auth @username, @password
      options[:method]  = method
      options[:headers] = { 'Authorization' => req['Authorization'] }
      AppEngine::URLFetch.fetch(url, options)
    end
  end
end