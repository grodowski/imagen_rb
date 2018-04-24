# frozen_string_literal: true

require 'rugged'

module Undercover
  # Base class for different kinds of input
  class Changeset
    extend Forwardable
    include Enumerable

    attr_reader :files
    def_delegators :files, :each, :'<=>'

    def initialize(dir, compare_base = nil)
      @dir = dir
      @repo = Rugged::Repository.new(dir)
      @compare_base = compare_base
      @files = {}
    end

    # TODO: needed???
    def root_path
      Pathname.new(repo.path).parent
    end

    def update
      full_diff.each_patch do |patch|
        filepath = patch.delta.new_file[:path]
        @files[filepath] = patch.each_hunk.map do |hunk|
          # TODO: optimise this to use line ranges!
          hunk.lines.select(&:addition?).map(&:new_lineno)
        end.flatten!
      end
      self
    end

    private

    # Diffs `head` or `head` + `compare_base` (if exists),
    # as it makes sense to run Undercover with the most recent file versions
    def full_diff
      base = compare_base_obj || head
      base.diff(repo.index).merge!(repo.index.diff)
    end

    def compare_base_obj
      return nil unless compare_base
      repo.lookup(repo.merge_base(compare_base.to_s, head))
    end

    def head
      repo.head.target
    end

    attr_reader :repo, :compare_base
  end
end
