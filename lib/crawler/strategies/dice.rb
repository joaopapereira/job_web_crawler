require 'crawler/searcher/searcher'
require 'crawler/searcher/job'
require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
module Crawler
module Strategies
class Dice < Crawler::Searcher::Searcher
  def search(term)
    page = HTTParty.get("http://service.dice.com/api/rest/jobsearch/v1/simple.xml?text=#{term.gsub(/ /, '%20')}")

    to_visit = []
    page["result"]["resultItemList"]["resultItem"].each do |link|
      to_visit << link["detailUrl"].gsub(/ /, '-')
    end

    all_jobs = []
    to_visit.each do |link|
      new_page = HTTParty.get(link)

      job = Searcher::Job.new
      parsed_page = Nokogiri::HTML(new_page)
      text = parsed_page.css('#jobdescSec').text
      if text.size > 1
        job.title = parsed_page.css('#jt').text
        job.description = text
        all_jobs << job
      end
    end

    add_result(term.to_sym, all_jobs)
  end
end
end
end
