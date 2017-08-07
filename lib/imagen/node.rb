# frozen_string_literal: true

module Imagen
  module Node
    # Abstract base class
    class Base
      attr_reader :name, :children

      def initialize
        @children = []
      end

      def build_from_ast(_ast)
        raise NotImplementedError
      end
    end

    # Root node for a given directory
    class Root < Base
      attr_reader :dir

      def build_from_dir(dir)
        @dir = dir
        list_files.each do |path|
          Imagen::Visitor.traverse(Parser::CurrentRuby.parse_file(path), self)
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
        tap { @name = ast_node.children[0].children[1].to_s }
      end
    end

    # Represents a Ruby class
    class Class < Base
      def build_from_ast(ast_node)
        tap { @name = ast_node.children[0].children[1].to_s }
      end
    end

    # Represents a Ruby class method
    class CMethod < Base
      def build_from_ast(ast_node)
        tap { @name = ast_node.children[1].to_s }
      end
    end

    # Represents a Ruby instance method
    class IMethod < Base
      def build_from_ast(ast_node)
        tap { @name = ast_node.children[0].to_s }
      end
    end
  end
end
