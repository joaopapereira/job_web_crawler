module Crawler
module Searcher
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
end
end