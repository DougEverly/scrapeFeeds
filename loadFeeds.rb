#!/usr/bin/env jruby

require 'rubygems'
require 'rexml/Document'
require 'mechanize'
require 'pp'
require 'sequel'
require 'jdbc/mysql'
require 'optparse'

@user = 'root'
@pass = 'pass'
@host = '127.0.0.1'
@database = 'Reader'
@port = '3306'
@file = 'MySubscriptions.opml'

OptionParser.new do |opts|
  # opts.banner = "Usage: example.rb [options]"

  opts.on("-u", "--user USER", "MySQL username") do |user|
    @user = user
  end

  opts.on("-p", "--pass PASSWORD", "MySQL password") do |pass|
    @pass = pass
  end

  opts.on("-h", "--host HOST", "MySQL host") do |host|
    @host = host
  end

  opts.on("-d", "--database DATABASE", "MySQL database") do |database|
    @database = database
  end

  opts.on("-P", "--port PORT", "MySQL port") do |port|
    @port = port
  end
  
  opts.on("-f", "--opml FILE", "Path to OPML file") do |file|
    @file = file
  end
  
  

end.parse!


def parse_opml(opml_node, parent_names=[])
  feeds = {}
  opml_node.elements.each('outline') do |el|
    if (el.elements.size != 0)
      feeds.merge!(parse_opml(el, parent_names + [el.attributes['text']]))
    end
    if (el.attributes['xmlUrl'])
      feeds[el.attributes['title']] = el.attributes['xmlUrl']
    end
  end
  return feeds
end

@db =  Sequel.connect("jdbc:mysql://#{@host}:#{@port}/#{@database}?user=#{@user}&password=#{@pass}")

opml = REXML::Document.new(File.read(@file))
feeds = @db[:feeds]
parse_opml(opml.elements['opml/body']).each do |name, url|
  feeds.insert(:name => name, :url => url)
end
