# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  add_filter(/^\/spec\//)
end

require 'rspec'
require 'imagen'

require 'undercover'

# Matchers compatible with Imagen::Node::Base#find_all
def of_type(type)
  ->(node) { node.is_a?(type) }
end

def with_name(name)
  ->(node) { node.name == name }
end
