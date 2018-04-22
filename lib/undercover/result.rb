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

    # TODO: create a formatter interface instead and add some tests.
    # TODO: re-enable rubocops
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    #
    # Zips coverage data (that doesn't include any non-code lines) with
    # full source for given code fragment (this includes whitespace).
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
      pad = node.last_line.to_s.length
      lines = pretty_print_lines.map do |covered, (num, line)|
        formatted_line = "#{num.to_s.rjust(pad)}: #{line}"
        if line.strip.length.zero?
          Rainbow(formatted_line).darkgray.dark
        elsif covered.nil?
          Rainbow(formatted_line).darkgray.dark + \
            Rainbow(' hits: n/a').italic.darkgray.dark
        elsif covered.positive?
          Rainbow(formatted_line).bold.lawngreen + \
            Rainbow(" hits: #{covered}").italic.darkgray.dark
        elsif covered.zero?
          Rainbow(formatted_line).bold.maroon + \
            Rainbow(" hits: #{covered}").italic.darkgray.dark
        end
      end.join("\n")
      puts lines
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def inspect
      "#<Undercover::Report::Result:#{object_id}" \
      " name: #{node.name}, coverage: #{coverage_f}>"
    end
  end
end
