#!/usr/bin/env ruby
# -*- ruby -*-

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

def getTime
  today = Time.now
  today.strftime("%Y-%m-%d")
end

def getOneSentence
  # 'http://dict.youdao.com/infoline?apiversion=3.0&client=deskdict&date=2021-02-22'
  url = "http://dict.youdao.com/infoline?apiversion=3.0&client=deskdict&date=#{getTime}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  sens = data["cards"]
  senset = {}
  sens.each {|sen|
    eng = sen["title"]
    han = sen["summary"]
    next if sen["title"].empty? || sen["summary"].empty? || senset.keys.include?(eng)
    senset[eng] = han
  }
  File.open("en.html","a+") do |f|
    senset.each { |key, value| f.puts key + "<br />" + value + "<br /><br />" }
  end
end

getOneSentence