# frozen_string_literal: true

require 'optparse'

module Undercover
  class Options
    RUN_MODE = [
      RUN_MODE_DIFF_STRICT = :diff_strict, # warn for changed lines
      # RUN_MODE_DIFF_FILES  = :diff_files, # warn for changed whole files
      # RUN_MODE_ALL         = :diff_all, # warn for allthethings
      # RUN_MODE_FILES       = :files # warn for specific files (cli option)
    ].freeze

    OUTPUT_FORMATTERS = [
      OUTPUT_STDOUT = :stdout, # outputs warnings to stdout with exit 1
      # OUTPUT_CIRCLEMATOR = :circlemator # posts warnings as review comments
    ].freeze

    attr_accessor :lcov, :path, :git_dir

    def initialize
      # TODO: use run modes
      # TODO: use formatters
      @run_mode = RUN_MODE_DIFF_STRICT
      @enabled_formatters = [OUTPUT_STDOUT]
      # set defaults
      self.lcov = guess_lcov_path
      self.path = '.'
      self.git_dir = '.git'
    end

    # rubocop:disable Metrics/MethodLength
    def parse(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: example.rb [options]'

        opts.on_tail('-h', '--help', 'Prints this help') do
          puts(opts)
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail('--version', 'Show version') do
          puts Version
          exit
        end

        lcov_path_option(opts)
        project_path_option(opts)

        # TODO: parse dem other options and assign to self
        # --compare (accepts sha or branch, defaults nil)
        # --git-dir (git dir, default '.git')
        # --quiet (skip progress bar)
        # --exit-status (do not print report, just exit)
        # --ruby-version (string, like '2.4.4', how to support in parser?)
      end.parse(args)
      self
    end
    # rubocop:enable Metrics/MethodLength

    private

    def lcov_path_option(parser)
      parser.on('-l', '--lcov path') do |path|
        self.lcov = path
      end
    end

    def project_path_option(parser)
      parser.on('-p', '--path path') do |path|
        self.path = path
      end
    end

    def guess_lcov_path
      project_dir = Pathname.pwd.split.last.to_s
      File.join(project_dir, 'coverage', 'lcov', "#{project_dir}.lcov")
    end
  end
end
