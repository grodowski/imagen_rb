# frozen_string_literal: true

require 'undercover'

module Undercover
  module CLI
    # TODO: Report calls >parser< for each file instead of
    # traversing the whole project at first!

    # TODO: add executable in ./bin later
    def self.run(args = ARGV)
      opts = Undercover::Options.new.parse(args)
      Undercover::Report.new(opts.lcov, opts.path, opts.git_dir)
      0
    end
  end
end
