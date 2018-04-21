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
end
