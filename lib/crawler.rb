require "crawler/version"
require "pry"
require 'crawler/strategies/indeed'
require 'crawler/strategies/craigs_list'
require 'crawler/results'
require 'crawler/output/java_file'

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
      
      result = Results.new
      all_crawlers.each do |crawler|
        result.add_result crawler
      end
      
      Pry.start(binding)
      output = nil
      output = Output::JavaFile.new('Stuff') if options.has_key? :output_java
      if not output.nil?
        output.output result
      else
        puts result
      end
    end
  end
  
end
