# frozen_string_literal: true

module Undercover
  class Result
    attr_reader :node, :coverage

    def initialize(node, file_cov)
      @node = node
      @coverage = file_cov.select do |ln, _|
        ln > node.first_line && ln < node.last_line
      end
    end

    def coverage_f
      covered = coverage.sum { |ln| ln[1].positive? ? 1 : 0 }
      (covered.to_f / coverage.size).round(4)
    end

    # TODO: create a formatter interface instead and add some tests
    # Zips coverage data (that doesn't include any non-code lines) with
    # full source for given code fragment (that includes whitespace).
    def pretty_print_lines
      cov_enum = coverage.each
      cov_source_lines = (node.first_line..node.last_line).map do |line_no|
        cov_line_no = begin
          cov_enum.peek[0]
        rescue StopIteration
          -1
        end
        cov_enum.next[1] if cov_line_no == line_no
      end
      cov_source_lines.zip(node.source_lines_with_numbers)
    end

    # TODO: create a formatter interface instead!
    def pretty_print
      lines = pretty_print_lines.map do |covered, (num, line)|
        if covered == nil
          "n/a   #{num.to_s.rjust(5)}: #{line}"
        elsif covered.positive?
          "#{Rainbow(covered.to_s.ljust(5)).bold.lawngreen} #{Rainbow(num.to_s.rjust(5)).gray}: #{line}"
        elsif covered.zero?
          "#{Rainbow('X'.ljust(5)).bold.maroon} #{Rainbow(num.to_s.rjust(5)).gray}: #{line}"
        end
      end.join("\n")
      puts lines
    end

    def inspect
      "#<Undercover::Report::Result:#{object_id}" \
      " name: #{node.name}, coverage: #{coverage_f}>"
    end
  end
end
