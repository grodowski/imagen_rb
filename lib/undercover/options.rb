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
        # add --commit option (accepts sha, 'staged' or 'unstaged')
      end.parse!(args)
    end
  end
end

# we need the same stuff we have in structure which has no git!
# so, stitch all the things (merge_base + staged + unstaged???)

# TODO: stale coverate lcov error, re-run dem specs

# -previous commit
# -specific sha/branch/tag

# when :unstaged, :index
#   [head_commit_sha, @repo.index.diff(options)]
# when :staged
#   [head_commit_sha, head.diff(@repo.index, options)]
# else
#   merge_base = merge_base(commit)
#   patches = @repo.diff(merge_base, head, options)
#   [merge_base, patches]
