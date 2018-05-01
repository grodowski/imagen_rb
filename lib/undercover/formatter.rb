# frozen_string_literal: true

module Undercover
  class Formatter
    def initialize(results)
      @results = results
    end

    def to_s
      @results.map do |res|
        "🚨 warning: node `#{res.node.name}` needs test coverage! (" \
        "type: #{res.node.class}, loc: #{res.file_path_with_lines}, " \
        "coverage: #{res.coverage_f * 100}%\n" +
          res.pretty_print
      end.join("\n---\n")
    end
  end
end
