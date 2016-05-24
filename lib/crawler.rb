require "crawler/version"
require "pry"
require 'crawler/strategies/indeed'
require 'crawler/strategies/craigs_list'

require 'thread'

module Crawler
  
  
  class Crawler
    def run options
      mutex = Mutex.new
      puts options
      all_crawlers = []
      all_crawlers << Strategies::Indeed.new(mutex) if options.has_key? :use_indeed
      all_crawlers << Strategies::CraigsList.new(mutex) if options.has_key? :use_craiglist
      
      options[:expressions].each do |expression|
        all_crawlers.each do |crawler|
          crawler.search(expression)
        end
      end
      Pry.start(binding)
    end
  end
  
end
