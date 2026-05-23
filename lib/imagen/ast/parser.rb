# frozen_string_literal: true

require 'prism'
require 'imagen/ast/prism_builder'

module Imagen
  @parser_version = 'current' # default to runtime ruby syntax

  class << self
    attr_accessor :parser_version
  end

  AVAILABLE_RUBY_VERSIONS = %w[
    ruby33
    ruby34
    ruby40
    current
  ].freeze

  module AST
    class Parser
      def self.parse_file(filename)
        new.parse_file(filename)
      end

      def self.parse(input, file = '(string)')
        new.parse(input, file)
      end

      # @param parser_version [String] ruby syntax version (e.g. 'ruby33', 'ruby34', 'current')
      def initialize(parser_version = Imagen.parser_version)
        validate_version(parser_version)

        const_name = if parser_version == 'current'
                       'ParserCurrent'
                     else
                       # e.g. "ruby34" -> "Parser34"
                       "Parser#{parser_version.delete_prefix('ruby')}"
                     end
        @parser_klass = ::Prism::Translation.const_get(const_name)
      end

      def parse_file(filename)
        parse(File.read(filename), filename)
      end

      def parse(input, file = '(string)')
        buffer = ::Parser::Source::Buffer.new(file)
        buffer.source = input
        parser.parse(buffer)
      end

      def parser
        @parser_klass.new(AST::PrismBuilder.new).tap do |parser|
          diagnostics = parser.diagnostics
          diagnostics.all_errors_are_fatal = true
          diagnostics.ignore_warnings = true
        end
      end

      private

      def validate_version(parser_version)
        return if AVAILABLE_RUBY_VERSIONS.include?(parser_version)

        raise ArgumentError, "#{parser_version} is not supported by imagen"
      end
    end
  end
end
