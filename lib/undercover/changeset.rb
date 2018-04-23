# frozen_string_literal: true

require 'rugged'

module Undercover
  # Base class for different kinds of input
  class Changeset
    extend Forwardable
    include Enumerable

    attr_reader :files
    def_delegators :files, :each, :'<=>'

    def initialize(dir)
      @repo = Rugged::Repository.new(dir)
      @files = {}
    end

    def root_path
      Pathname.new(repo.path).parent
    end

    def update
      full_diff.each_patch do |patch|
        filepath = File.join(root_path, patch.delta.new_file[:path])
        @files[filepath] = patch.each_hunk.map do |hunk|
          # TODO: optimise this to use line ranges!
          hunk.lines.select(&:addition?).map(&:new_lineno)
        end.flatten!
      end
    end

    private

    # Combines index with staged diffs, as it makes sense
    # to run Undercover with the most recent file versions
    def full_diff
      head.diff(repo.index).merge!(repo.index.diff)
    end

    def head
      repo.head.target
    end

    attr_reader :repo
  end
end
