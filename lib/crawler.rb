require "crawler/version"
require "pry"
require 'crawler/strategies/indeed'
require 'crawler/strategies/craigs_list'
require 'crawler/strategies/dice'
require 'crawler/results'
require 'crawler/output/java_file'

require 'thread'

module Crawler


  class Crawler
    def run options
      mutex = Mutex.new
      all_crawlers = []
      all_crawlers << Strategies::Indeed.new(mutex) if options.has_key? :use_indeed
      all_crawlers << Strategies::CraigsList.new(mutex) if options.has_key? :use_craiglist
      all_crawlers << Strategies::Dice.new(mutex) if options.has_key? :use_dice

      options[:expressions].each do |expression|
        threads = []
        puts "Start searching for: #{expression}"
        all_crawlers.each do |crawler|
          threads << Thread.new do
            crawler.search(expression)
          end
        end
        threads.map(&:join)
        puts "Done"
      end

      result = Results.new
      all_crawlers.each do |crawler|
        result.add_result crawler
      end

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
