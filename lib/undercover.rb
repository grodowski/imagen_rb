# frozen_string_literal: true

$LOAD_PATH << 'lib'
require 'imagen'
require 'rainbow'

require 'undercover/lcov_parser'
require 'undercover/result'

# TODO: Gemify dat!
module Undercover
  class Report
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
