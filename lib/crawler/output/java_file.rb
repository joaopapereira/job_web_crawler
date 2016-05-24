require 'crawler/output/outputter'
require 'erb'
module Crawler
module Output
class JavaFile < Outputter
    include ERB::Util
    def initialize(class_name)
        @mergedResult = {}
        @class_name = class_name
    end
    def output(result)
        @mergedResult = result
        
        rendered = ERB.new(get_template())
        File.write("#{@class_name}.java", rendered.result(binding))
    end
    def get_template()
        %{
            public class <% @class_name %> {
            <% @mergedResult.results.each do |query_string, all_jobs| %>
            public static final String[] <%=query_string.to_s.gsub(/ /,'_')%> = {
                <% for job in all_jobs %>
                "<%= job.one_liner.gsub(/\\n/, " ").gsub(/'|"/, '') %>",
                <% end %>
                ""
            };
            <% end %>
            }
        }
    end
end
end
end