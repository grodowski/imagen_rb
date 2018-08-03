# frozen_string_literal: true

require 'parser/current'
require 'imagen/ast/builder'

module Imagen
  module AST
    module Parser
      def self.parse_file(filename)
        parse(File.read(filename), filename)
      end

      def self.parse(input, file = '(string)')
        buffer = ::Parser::Source::Buffer.new(file)
        buffer.source = input
        default_parser.parse(buffer)
      end

      def self.default_parser
        ::Parser::CurrentRuby.new(AST::Builder.new).tap do |parser|
          diagnostics = parser.diagnostics
          diagnostics.all_errors_are_fatal = true
          diagnostics.ignore_warnings = true
        end
      end
    end
  end
end
