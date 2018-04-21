# frozen_string_literal: true

require 'rspec'
require 'imagen'

# Reopen Imagen::Node::Base to add convenience spec finders
module Imagen
  module Node
    class Base
      def find_all(matcher, ret = [])
        ret.tap do
          ret << self if matcher.call(self)
          children.each { |child| child.find_all(matcher, ret) }
        end
      end
    end
  end
end

# Matcher compatible with Imagen::Node::Base#find_all
# This method reeks of :reek:UtilityFunciton
def of_type(type)
  ->(node) { node.is_a?(type) }
end
