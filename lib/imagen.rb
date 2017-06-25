# frozen_string_literal: true

$LOAD_PATH << 'lib'

require 'imagen/node'
require 'imagen/visitor'
require 'imagen/clone'
require 'imagen/builder'

# Base module
module Imagen
  EXCLUDE_RE = /_(spec|test).rb$/
end
