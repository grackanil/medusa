#!/usr/bin/env ruby
# -*- ruby -*-

require 'net/http'
require 'net/https'
require 'uri'
require 'json'
def getPoem(token, appId, apiKey)
  url = URI("https://v2.jinrishici.com/sentence")
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["X-User-Token"] = token
  res = https.request(request).body
  response = JSON.parse(res)
  data = response["data"]
  origin = data["origin"]
  puts data
  File.open("result.html","a+") do |f|
    f.puts "#{origin["title"]}-#{origin["author"]}<br />"
    matchTags = data["matchTags"]
    f.puts "#{origin["dynasty"]}  ##{matchTags.join("#")}#<br />" if matchTags && matchTags.size > 0
    content = origin["content"]
    content.each { |sequence|
      f.puts "#{sequence}<br />"
    }
    translates = origin["translate"]
    if translates && translates.size > 0
      f.puts "译文<br />"
      translates.each { |seq| f.puts "#{seq}<br />" }
    end
  end
end

getPoem(ARGV[0], ARGV[1], ARGV[2])