# frozen_string_literal: true

require 'optparse'

module Undercover
  class Options
    RUN_MODE = [
      RUN_MODE_DIFF_STRICT = :diff_strict, # warn for changed lines
      RUN_MODE_DIFF_FILES  = :diff_files, # warn for changed whole files
      RUN_MODE_ALL         = :diff_all, # warn for allthethings
      RUN_MODE_FILES       = :files # warn for specific files (cli option)
    ].freeze

    OUTPUT_FORMATTERS = [
      OUTPUT_STDOUT      = :stdout, # outputs warnings to stdout with exit 1
      OUTPUT_CIRCLEMATOR = :circlemator # posts warnings as review comments
    ].freeze

    def initialize
      # TODO: use run modes
      # TODO: use formatters
      @run_mode = RUN_MODE_DIFF_STRICT
      @enabled_formatters = [OUTPUT_STDOUT]
    end

    def parse(args)
      OptionParser.new do |opts|
        # TODO: parse dem options and assign to self
        # add --commit option (accepts sha)
      end.parse!(args)
    end
  end
end
