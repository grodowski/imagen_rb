# frozen_string_literal: true

require 'prism'

module Imagen
  module AST
    # An AST Builder for prism-based parsing (Ruby >= 3.4 or current Ruby > 3.3).
    # Must inherit from Prism::Translation::Parser::Builder which carries support
    # for modern node types absent in Parser::Builders::Default.
    class PrismBuilder < ::Prism::Translation::Parser::Builder
      # This is a work around for parsing ruby code with invalid UTF-8
      # https://github.com/whitequark/parser/issues/283
      def string_value(token)
        value(token)
      end
    end
  end
end
