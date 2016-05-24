module Crawler
    class Results
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
end