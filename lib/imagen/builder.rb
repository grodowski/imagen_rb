# frozen_string_literal: true

module Imagen
  # Builder is responsible for wrapping all operations to create a result
  class Builder
    attr_reader :repo_url, :dir

    def initialize(repo_url)
      @repo_url = repo_url
      @dir = Dir.mktmpdir
    end

    def build
      Clone.perform(repo_url, dir)
      `ls -alh #{dir}`
      # TODO: create a linked data model (Base, Dir, Module, Class, Function)
      # TODO: build & match relevant .rb files
      # TODO: parse and traverse each file to build the tree to return
      teardown
    end

    private

    def teardown
      FileUtils.remove_entry dir
    end
  end
end
