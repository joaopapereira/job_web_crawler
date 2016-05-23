require 'crawler/searcher/searcher'
require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
module Crawler
module Strategies
class Indeed < Crawler::Searcher::Searcher
  def search(term)
    page = HTTParty.get("http://rss.indeed.com/rss?q=#{term.gsub(/ /, '%20')}")

    parsed_page = Nokogiri::XML(page)
    all_links = parsed_page.xpath("//item")
    to_visit = []
    
    Pry.start(binding)
    all_links.each do |link|
      to_visit << link.children.text
    end


    all_lines = []

    to_visit.each do |link|
      new_page = HTTParty.get(link)

      parsed_page = Nokogiri::HTML(new_page)
      text = parsed_page.css('#job_summary').text
      if text.size > 1
        all_lines << text
      end
    end

    add_result(term.to_sym, all_lines)
  end
end
end
end