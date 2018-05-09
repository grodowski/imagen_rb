# frozen_string_literal: true

$LOAD_PATH << 'lib'

require 'imagen/node'
require 'imagen/visitor'
require 'imagen/clone'
require 'imagen/remote_builder'

# Base module
module Imagen
  EXCLUDE_RE = /_(spec|test).rb$/

  def self.from_local(dir)
    Node::Root.new.build_from_dir(dir)
  end

  def self.from_remote(repo_url)
    RemoteBuilder.new(repo_url).build
  end
end
