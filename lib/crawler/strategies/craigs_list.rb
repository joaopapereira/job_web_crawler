require 'crawler/searcher/searcher'
require 'crawler/searcher/job'
require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
module Crawler
module Strategies
class CraigsList < Crawler::Searcher::Searcher
  def search(term)
    page = HTTParty.get("https://newyork.craigslist.org/search/jjj?format=rss&query=#{term.gsub(/ /, '%20')}")

    parsed_page = Nokogiri::XML(page)
    all_links = parsed_page.xpath("//rdf:li")
    to_visit = []
    all_links.each do |link|
      to_visit << link.attribute("resource").value
    end


    all_jobs = []
    to_visit.each do |link|
      new_page = HTTParty.get(link)

      job = Searcher::Job.new
      parsed_page = Nokogiri::HTML(new_page)
      text = parsed_page.css('#postingbody').text
      if text.size > 1
        job.title = parsed_page.css('#titletextonly').text
        job.description = text
        all_jobs << job
      end
    end

    add_result(term.to_sym, all_jobs)
  end
end
end
end