# frozen_string_literal: true

module Imagen
  # Builder is responsible for wrapping all operations to create a result
  class Builder
    def self.build(repo_url)
      new(repo_url).build
    end

    attr_reader :repo_url

    def initialize(repo_url)
      @repo_url = repo_url
    end

    def build
      repo_url
    end
  end
end
