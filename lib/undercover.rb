# frozen_string_literal: true

$LOAD_PATH << 'lib'
require 'imagen'
require 'rainbow'

require 'undercover/lcov_parser'
require 'undercover/result'
require 'undercover/changeset'

# TODO: Gemify dat!
module Undercover
  class Report
    attr_reader :changeset,
                :code_structure,
                :lcov,
                :results

    def initialize(lcov_report_path, code_dir)
      @lcov = LcovParser.parse(File.open(lcov_report_path))
      # TODO: optimise by building changeset structure only!
      @code_structure = Imagen.from_local(code_dir)
      @changeset = Changeset.new(code_dir).update
      @results = {}
    end

    # TODO: this is experimental and might be incorrect!
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def build
      each_result_arg do |filename, coverage, imagen_node|
        results[filename] ||= []
        results[filename] << Result.new(imagen_node, coverage, filename)
      end

      flagged_results = Set.new
      changeset.each_changed_line do |filepath, line_no|
        start_line_comp = lambda do |node_line|
          return 1 if line_no < node_line
          line_no - node_line
        end

        res = results[filepath].select { |rest| rest.first_line <= line_no }
                               .min do |res1, res2|
          start_line_comp.call(res1.first_line) <=> start_line_comp.call(res2.first_line)
        end

        if res.uncovered?(line_no)
          # TODO: ALSO ADD LINE INFO!
          flagged_results << res
        end
      end
      self
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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
