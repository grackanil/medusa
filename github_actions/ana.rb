#!/usr/bin/env ruby
# -*- ruby -*-

require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'digest'

def ana(secret_key, safe_token)
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
  uploadBmob(secret_key, safe_token, res)
end

def getTimestamp
  Time.now.to_i * 1000
end

def md5(sign)
  Digest::MD5.hexdigest sign
end

# 获取 16 位随机串
def getNoncestr
  chars = ('a'..'z').to_a + (0..9).to_a + ('A'..'Z').to_a
  chars.shuffle[0..15].join
end

# 上传至 Bmob 后台
# http://doc.bmob.cn/data/restful/develop_doc/#_4
def uploadBmob(secret_key, safe_token, res)
  timestamp = getTimestamp()
  path = "/1/classes/Ana"
  noncestr = getNoncestr()
  sign = md5(path + timestamp.to_s + safe_token + noncestr)
  url = URI("https://api2.bmob.cn" + path)
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Post.new(url)
  request["content-type"] = "application/json"
  request["X-Bmob-SDK-Type"] = "API"
  request["X-Bmob-Safe-Timestamp"] = timestamp
  request["X-Bmob-Noncestr-Key"] = noncestr
  request["X-Bmob-Secret-Key"] = secret_key
  request["X-Bmob-Safe-Sign"] = sign
  request.body = res
  response = https.request(request)
  puts response.read_body
end

ana(ARGV[0], ARGV[1])