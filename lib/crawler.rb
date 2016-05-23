require "crawler/version"
require "pry"
require 'crawler/strategies/indeed'

require 'thread'

module Crawler
  
  
  class Crawler
    def run options
      mutex = Mutex.new
      puts options
      all_crawlers = []
      all_crawlers << Strategies::Indeed.new(mutex) if options.has_key? :use_indeed
      
      options[:expressions].each do |expression|
        all_crawlers.each do |crawler|
          crawler.search(expression)
        end
      end
      Pry.start(binding)
    end
  end
  
end
