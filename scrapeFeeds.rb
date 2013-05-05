#!/usr/bin/env jruby

require 'rubygems'
require 'mechanize'
require 'pp'
require 'rss'
require 'open-uri'
require 'sequel'
require 'jdbc/mysql'
require "digest/md5"
require 'hpricot'
require 'htmlentities'
require 'optparse'

@user = 'root'
@pass = 'pass'
@host = '127.0.0.1'
@database = 'Reader'
@port = '3306'

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

end.parse!


class RSSArticle
  def initialize(xml = nil)
    parse xml if not xml.nil?
  end
  
  def parse(xml)
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
  end
end

class RSSFeed
  
  attr_accessor :version, :title, :link, :description
  
  def initialize(xml = nil)
    @feed = RSS::Parser.parse(xml, false, true)
    @feed.items.each do |item|
      puts "============"
      pp item
      
    end
  end
  
  def parse
      
  end
end

class Aggregator
  
  attr_accessor :workers, :results
  
  def initialize(host, port, database, user, pass)
    @jobs = SizedQueue.new 1000
    @articles = SizedQueue.new 1000
    @results = Array.new
    @workers = 40
    c = "jdbc:mysql://#{host}:#{port}/#{database}?user=#{user}&password=#{pass}"
    @db =  Sequel.connect(c)
    create_pool
  end

  def worker
    puts "worker start"
    mech = Mechanize.new
    until (@jobs == (feed = @jobs.pop))
      # pp feed
      url = feed[:url]
      # puts "processing #{url}"
      begin
        # open(url) do |page|
        #   rss = RSSFeed.new page.content
        # end
        mech.get(url) do |page|
        # open(url) do |page|
        
          # puts page.content
          rss = RSS::Parser.parse(page.content)
          rss.items.each do |item|

            article = {
              :fkFeedId => feed[:pkFeedId],
              :title => item.title.to_s,
              :link => item.link.to_s,
              :firstSeen => Time.now.to_s
            }
            
            if item.respond_to? :updated
              article[:date] = trim(item.updated, :updated)
            end
            if item.respond_to? :published
              article[:published] = trim(item.published, :published)
            end

            articles = @db[:articles]
            articles.insert article
            
          end
        end
      rescue Exception => e  
        puts "Cannot process #{url}: #{e.message}"
      end
    end
    puts "worker done"
  end
  
  def trim(s, tag)
    d = Hpricot(s.to_s)
    # puts "HERE: " + (d/tag.to_s).inner_html
    HTMLEntities.new.decode (d/tag.to_s).inner_html
  end

  def feeds
    feeds = @db[:feeds]
  end

  def create_pool
    @threads = Array.new
    @workers.times do |i|
      @threads << Thread.new do 
        puts "adding thread"
        worker
      end
    end
  end

  def start
    feeds.each do |feed|
      @jobs << feed
    end
    @workers.times do |thread|
      @jobs << @jobs
    end
  end
  
  def stop
    @threads.each do |thread|
      thread.join
    end
    puts "found: #{@results.size}"
  end

end

agg = Aggregator.new(@host, @port, @database, @user, @pass)
agg.start
agg.stop
puts "Found #{agg.results.size}"