# frozen_string_literal: true

$LOAD_PATH << 'lib'
require 'imagen'
require 'pry'

require 'rainbow'

# TODO: Gemify dat!
module Undercover
  LcovParseError = Class.new(StandardError)

  class LcovParser
    attr_reader :io, :source_files

    def initialize(lcov_io)
      @io = lcov_io
      @source_files = {}
    end

    def self.parse(lcov_report_path)
      lcov_io = File.open(lcov_report_path)
      new(lcov_io).parse
    end

    def parse
      io.each(&method(:parse_line))
      io.close
      self
    end

    private

    # rubocop:disable Metrics/MethodLength, Style/SpecialGlobalVars
    def parse_line(line)
      case line
      when /^SF:([\.\/\w]+)/
        @current_filename = $~[1].gsub(/^\.\//, '')
        source_files[@current_filename] = []
      when /^DA:(\d+),(\d+)/
        line_no = $~[1]
        covered = $~[2]
        source_files[@current_filename] << [line_no.to_i, covered.to_i]
      when /^end_of_record$/, /^$/
        @current_filename = nil
      else
        raise LcovParseError, "could not recognise '#{line}' as valid LCOV"
      end
    end
    # rubocop:enable Metrics/MethodLength, Style/SpecialGlobalVars
  end

  class Report
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

    attr_reader :lcov, :code_structure, :results

    def initialize(lcov_report_path, code_dir)
      @lcov = LcovParser.parse(File.open(lcov_report_path))
      @code_structure = Imagen.from_local(code_dir)
      @results = {}
    end

    def build
      each_result_arg do |filename, coverage, imagen_node|
        results[filename] ||= []
        results[filename] << Result.new(imagen_node, coverage)
      end

      # build warnings for each node
      # formatters for CLI and for circlemator!
      # TODO: add configurable threshold?
      self
    end

    def all_results
      results.values.flatten
    end

    def inspect
      "#<Undercover::Report:#{object_id} results: #{results.size}>"
    end

    private

    def each_result_arg
      matches_path = lambda do |path|
        ->(node) { node.file_path.end_with?(path) }
      end

      lcov.source_files.each do |filename, coverage|
        code_structure.find_all(matches_path[filename]).each do |node|
          yield(filename, coverage, node)
        end
      end
    end
  end
end
