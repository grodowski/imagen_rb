# frozen_string_literal: true

module Imagen
  module Node
    # Abstract base class
    class Base
      attr_reader :ast_node,
                  :children,
                  :name

      def initialize
        @children = []
      end

      def build_from_ast(ast_node)
        tap { @ast_node = ast_node }
      end

      def file_path
        ast_node.location.name.source_buffer.name
      end

      def first_line
        ast_node.location.first_line
      end

      def last_line
        ast_node.location.last_line
      end
    end

    # Root node for a given directory
    class Root < Base
      attr_reader :dir

      def build_from_dir(dir)
        @dir = dir
        list_files.each do |path|
          Imagen::Visitor.traverse(Parser::CurrentRuby.parse_file(path), self)
        rescue Parser::SyntaxError => err
          warn "#{path}: #{err} #{err.message}"
        end
        self
      end

      private

      def list_files
        Dir.glob("#{dir}/**/*.rb").reject { |path| path =~ Imagen::EXCLUDE_RE }
      end
    end

    # Represents a Ruby module
    class Module < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[0].children[1].to_s }
      end
    end

    # Represents a Ruby class
    class Class < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[0].children[1].to_s }
      end
    end

    # Represents a Ruby class method
    class CMethod < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[1].to_s }
      end
    end

    # Represents a Ruby instance method
    class IMethod < Base
      def build_from_ast(ast_node)
        super
        tap { @name = ast_node.children[0].to_s }
      end
    end
  end
end
