# frozen_string_literal: true

# TODO: we need to defer that require
# default is 'parser/current'
# but where to pass an option???????
#

module Imagen
  @parser_version = 'current' # default to current runtime version

  class << self
    attr_accessor :parser_version
  end

  # AVAILABLE_RUBY_VERSIONS = %w[
  #   ruby18
  #   ruby19
  #   ruby20
  #   ruby21
  #   ruby22
  #   ruby23
  #   ruby24
  #   ruby25
  #   ruby26
  # ].freeze

  module AST
    # TODO: add specs for parser_klass??
    class Parser
      def self.parse_file(filename)
        new.parse_file(filename)
      end

      def self.parse(input, file = '(string)')
        new.parse(input, file)
      end

      # @param parser_klass [Parser::Base] specific parser type
      # when is that CurrentRuby evaluated?
      def initialize(parser_version = Imagen.parser_version)
        # TODO: validate available versions!!!

        require "parser/#{parser_version}"

        required_const = if parser_version == 'current'
                           'CurrentRuby'
                         else
                           parser_version.capitalize
                         end
        @parser_klass = ::Parser.const_get(required_const)
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
        @parser_klass.new(AST::Builder.new).tap do |parser|
          diagnostics = parser.diagnostics
          diagnostics.all_errors_are_fatal = true
          diagnostics.ignore_warnings = true
        end
      end
    end
  end
end
