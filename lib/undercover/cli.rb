# frozen_string_literal: true

require 'undercover'

module Undercover
  module CLI
    # TODO: Report calls >parser< for each file instead of
    # traversing the whole project at first!

    # TODO: add executable in ./bin later
    def self.run(args = ARGV)
      opts = Undercover::Options.new.parse(args)
      report = Undercover::Report.new(
        opts.lcov,
        opts.path,
        git_dir: opts.git_dir
      ).build
      warnings = report.build_warnings
      puts Undercover::Formatter.new(warnings)
      warnings.any? ? 1 : 0
    end
  end
end
