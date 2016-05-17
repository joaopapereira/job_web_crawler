require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
require 'erb'
require 'thread'

class Searcher
  def initialize(mutex)
    @results = {}
    @mutex = mutex
  end
  def search(term)
  end
  def add_result(term, values)
    @mutex.synchronize do
      @results[term.to_sym] = values
    end
  end
  def results()
    @results
  end
end

class Indeed < Searcher
  def search(term)
    page = HTTParty.get("http://rss.indeed.com/rss?q=#{term.gsub(/ /, '%20')}")

    parsed_page = Nokogiri::XML(page)
    all_links = parsed_page.xpath("//link")
    to_visit = []
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
class CraigsList < Searcher
  def search(term)
    page = HTTParty.get("https://newyork.craigslist.org/search/jjj?format=rss&query=#{term.gsub(/ /, '%20')}")

    parsed_page = Nokogiri::XML(page)
    all_links = parsed_page.xpath("//rdf:li")
    to_visit = []
    all_links.each do |link|
      to_visit << link.attribute("resource").value
    end


    all_lines = []
    to_visit.each do |link|
      new_page = HTTParty.get(link)

      parsed_page = Nokogiri::HTML(new_page)
      text = parsed_page.css('#postingbody').text
      if text.size > 1
        all_lines << text
      end
    end

    add_result(term.to_sym, all_lines)
  end
end

class ResultMerger
  def initialize
    @result = {}
  end
  def add_result(result)
    result.results.each do |key, values|
      @result[key] = [] || @result[key]
      @result[key] += values
    end
  end
  def results
    return @result
  end
end

@mutex = Mutex.new

query_string = 'software'

def term_template(term, lines)
  %{
      public static final String[] <%=term.gsub(/ /, '_')%> = {
        <% for line in lines %>
          "<%= line.gsub(/\\n/, " ") %>",
        <% end %>
        ""
      };
  }
end


all_terms = []

def java_file_template(all_terms)
    %{
      public class Stuff {
          <% for line in all_terms %>
            <%= all_terms %>
          <% end %>
      }
    }
end

@all_terms = {}


def get_template()
  %{
    public class Stuff {
      <% @mergedResult.results.each do |query_string, all_lines| %>
      public static final String[] <%=query_string.to_s.gsub(/ /,'_')%> = {
        <% for line in all_lines %>
          "<%= line.gsub(/\\n/, " ").gsub(/'|"/, '') %>",
        <% end %>
        ""
      };
      <% end %>
    }
  }
end

cl = CraigsList.new @mutex
cl.search("software developer")
@indeed_crawler = Indeed.new @mutex
t1 = Thread.new do
  @indeed_crawler.search("software developer")
  cl.search("software developer")
end
t2 = Thread.new do
  @indeed_crawler.search("line cook")
  cl.search("line cook")
end
t3 = Thread.new do
  @indeed_crawler.search("mason")
  cl.search("mason")
end
t4 = Thread.new do
  @indeed_crawler.search("retail")
  cl.search("retail")
end

t1.join
t2.join
t3.join
t4.join
@mergedResult = ResultMerger.new
@mergedResult.add_result @indeed_crawler
@mergedResult.add_result cl

rendered = ERB.new(get_template())
File.write('Stuff.java', rendered.result())


#Pry.start(binding)
