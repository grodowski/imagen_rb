# frozen_string_literal: true

require 'spec_helper'

describe Imagen::Node::Base do
  let(:ast) { Parser::CurrentRuby.parse_file('spec/fixtures/class.rb') }

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
      Parser::CurrentRuby.parse(input)
    )

    # TODO: do we need the trailing newline?
    expect(node.source + "\n").to eq <<-STR
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
