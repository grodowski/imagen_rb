# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

describe Imagen::Node::Base do
  let(:ast) { Imagen::AST::Parser.parse_file('spec/fixtures/class.rb') }

  it 'stores filename, first_line and last_line' do
    node = described_class.new.build_from_ast(ast)

    expect(node.first_line).to eq(3)
    expect(node.last_line).to eq(18)
    expect(node.file_path).to eq('spec/fixtures/class.rb')
  end

  it 'has access to source code' do
    input = <<-STR
      if 2 + 2 == 5
        puts 'wow'
      end
    STR

    node = described_class.new.build_from_ast(
      Imagen::AST::Parser.parse(input)
    )

    # TODO: do we need the trailing newline?
    expect("#{node.source}\n").to eq <<-STR
      if 2 + 2 == 5
        puts 'wow'
      end
    STR

    expect(node.source_lines_with_numbers).to eq(
      [
        [1, '      if 2 + 2 == 5'],
        [2, "        puts 'wow'"],
        [3, '      end']
      ]
    )
  end
end

describe Imagen::Node::Root do
  let(:input) do
    <<-STR
      if 2 + 2 == 5
        puts 'wow'
      end
    STR
  end

  describe '#human_name' do
    let(:node) do
      described_class.new.build_from_ast(Imagen::AST::Parser.parse(input))
    end

    it 'has human name' do
      expect(node.human_name).to eq('root')
    end
  end

  it 'builds from file' do
    node = described_class.new.build_from_file('spec/fixtures/class.rb')

    expect(node).to be_a(Imagen::Node::Root)
    expect(node.children[0].source_lines.length).to eq(17)
  end

  it 'prints syntax errors' do
    Tempfile.open do |f|
      f.write("do puts 'incomplete' end")
      f.flush
      ret = nil
      expect { ret = described_class.new.build_from_file(f.path) }
        .to output(/unexpected token kDO/).to_stderr
      expect(ret).to be_a(Imagen::Node::Root)
    end
  end

  it 'does not fail on invalid utf8 sequences' do
    Tempfile.open do |f|
      f.write('"\x87"')
      f.flush

      node = Imagen::Node::CMethod.new.build_from_ast(
        Imagen::AST::Parser.parse_file(f)
      )
      expect(node.ast_node.children.first).to eq("\x87")
    end
  end

  it 'reads files as UTF-8' do
    tf = Tempfile.new('ascii_file', encoding: Encoding::BINARY)
    tf.write("\x27\xE2\x8C\x9A\xEF\xB8\x8F\x27") # (clock emoji in quotes)
    tf.close

    node = Imagen::Node::CMethod.new.build_from_ast(
      Imagen::AST::Parser.parse_file(tf.path)
    )

    expect(node.ast_node.children.first).to eq('⌚️')

    tf.unlink
  end
end

describe Imagen::Node::Module do
  let(:input) do
    <<-STR
      module Foo
        if 2 + 2 == 5
          puts 'wow'
        end
      end
    STR
  end

  let(:node) do
    described_class.new.build_from_ast(Imagen::AST::Parser.parse(input))
  end

  it 'has human name' do
    expect(node.human_name).to eq('module')
  end

  describe "#empty_def?" do
    let(:module_node) do
      root = Imagen::Node::Root.new.build_from_ast(Imagen::AST::Parser.parse(input))
      root.children.first
    end

    context 'with an empty method def' do
      let(:input) do
        <<-STR
          module Foo
          end
        STR
      end

      it 'returns true for empty class methods' do
        expect(module_node).to be_empty_def
      end
    end

    context 'with a non-empty method def' do
      let(:input) do
        <<-STR
          module Foo
            attr_reader :bar
          end
        STR
      end

      it 'returns false for non-empty class methods' do
        expect(module_node).not_to be_empty_def
      end
    end
  end
end

describe Imagen::Node::Class do
  let(:input) do
    <<-STR
      class Bar
        if 2 + 2 == 5
          puts 'wow'
        end
      end
    STR
  end

  let(:node) do
    described_class.new.build_from_ast(Imagen::AST::Parser.parse(input))
  end

  it 'has human name' do
    expect(node.human_name).to eq('class')
  end

  describe "#empty_def?" do
    let(:class_node) do
      root = Imagen::Node::Root.new.build_from_ast(Imagen::AST::Parser.parse(input))
      root.children.first
    end

    context 'with an empty method def' do
      let(:input) do
        <<-STR
          class Foo
          end
        STR
      end

      it 'returns true for empty class methods' do
        expect(class_node).to be_empty_def
      end
    end

    context 'with a non-empty method def' do
      let(:input) do
        <<-STR
          class Foo
            attr_reader :bar
          end
        STR
      end

      it 'returns false for non-empty class methods' do
        expect(class_node).not_to be_empty_def
      end
    end
  end
end

describe Imagen::Node::CMethod do
  let(:input) do
    <<-STR
      class Tom
        def self.taylor
          puts 'wow'
        end
      end
    STR
  end

  let(:node) do
    Imagen::Node::CMethod.new.build_from_ast(Imagen::AST::Parser.parse(input))
  end

  it 'has human name' do
    expect(node.human_name).to eq('class method')
  end

  describe "#empty_def?" do
    let(:cmethod_node) do
      root = Imagen::Node::Root.new.build_from_ast(Imagen::AST::Parser.parse(input))
      root.children.first.children.first
    end

    context 'with an empty method def' do
      let(:input) do
        <<-STR
          class Tom
            def self.taylor
            end
          end
        STR
      end

      it 'returns true for empty class methods' do
        expect(cmethod_node).to be_empty_def
      end
    end

    context 'with a non-empty method def' do
      let(:input) do
        <<-STR
          class Tom
            def self.taylor
              1 + 1
            end
          end
        STR
      end

      it 'returns false for non-empty class methods' do
        expect(cmethod_node).not_to be_empty_def
      end
    end
  end
end

describe Imagen::Node::IMethod do
  let(:input) do
    <<-STR
      class Hello
        def darkness
          puts 'my old friend'
        end
      end
    STR
  end

  let(:node) do
    described_class.new.build_from_ast(Imagen::AST::Parser.parse(input))
  end

  it 'has human name' do
    expect(node.human_name).to eq('instance method')
  end

  describe "#empty_def?" do
    let(:imethod_node) do
      root = Imagen::Node::Root.new.build_from_ast(Imagen::AST::Parser.parse(input))
      root.children.first.children.first
    end

    context 'with an empty method def' do
      let(:input) do
        <<-STR
          class Tom
            def taylor
            end
          end
        STR
      end

      it 'returns true for empty class methods' do
        expect(imethod_node).to be_empty_def
      end
    end

    context 'with a non-empty method def' do
      let(:input) do
        <<-STR
          class Tom
            def taylor
              1 + 1
            end
          end
        STR
      end

      it 'returns false for non-empty class methods' do
        expect(imethod_node).not_to be_empty_def
      end
    end
  end
end

describe Imagen::Node::Block do
  let(:input) do
    <<-STR
      (0..1).each do
        puts 'my old friend, block'
      end
    STR
  end

  let(:node) do
    described_class.new.build_from_ast(Imagen::AST::Parser.parse(input))
  end

  it 'has a human name' do
    expect(node.human_name).to eq('block')
  end

  describe "#empty_def?" do
    let(:block_node) do
      root = Imagen::Node::Root.new.build_from_ast(Imagen::AST::Parser.parse(input))
      root.children.first
    end

    context 'with an empty method def' do
      let(:input) do
        <<-STR
          (0..1).each do
          end
        STR
      end

      it 'returns true for empty class methods' do
        expect(block_node).to be_empty_def
      end
    end

    context 'with a non-empty method def' do
      let(:input) do
        <<-STR
          (0..1).each do
            puts 'foo'
          end
        STR
      end

      it 'returns false for non-empty class methods' do
        expect(block_node).not_to be_empty_def
      end
    end
  end
end
