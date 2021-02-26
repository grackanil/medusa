#!/usr/bin/env ruby
# -*- ruby -*-

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

def ana(appId, apiKey)
  # https://developer.hitokoto.cn/
  types = {
      "a" => "动画",
      "b" => "漫画",
      "c" => "游戏",
      "d" => "文学",
      "e" => "原创",
      "f" => "来自网络",
      "g" => "其他",
      "h" => "影视",
      "i" => "诗词",
      "j" => "网易云",
      "k" => "哲学",
      "l" => "抖机灵"
  }
  query=types.keys.map!{|key| "c=#{key}"}.join("&")
  url = URI("https://v1.hitokoto.cn?#{query}")
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  res = https.request(request).body
  puts res.class
  response = JSON.parse(res)
  File.open("ana.html","a+") do |f|
    key = response["type"]
    from = response["from"]
    from_who = response["from_who"]
    from_who_str = from_who ? "#{from_who}" : "😶‍"
    from_str = from ? "#{from}" : "🏙"
    f.puts "#{response["hitokoto"]}<br />" if response["hitokoto"]
    f.puts "type:#{types[key]}<br />"
    f.puts "who:‍#{from_who_str} where:#{from_str}<br />"
  end

  url = URI("https://api2.bmob.cn/1/classes/Ana")
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(url)
  request["X-Bmob-Application-Id"] = appId
  request["X-Bmob-REST-API-Key"] = apiKey
  request["Content-Type"] = "application/json"
  request.body = res
  response = https.request(request)
  puts response.read_body
end

ana(ARGV[0], ARGV[1])