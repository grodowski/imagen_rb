# frozen_string_literal: true

describe Imagen::AST::Parser do
  let(:ruby20) do
    <<-CODE
      def works? keyword:
        'nope'
      end
    CODE
  end

  it 'uses ruby 1.9 syntax given an option' do
    parser = described_class.new('ruby19')

    expect { parser.parse(ruby20) }.to raise_error(
      Parser::SyntaxError,
      'unexpected token tLABEL'
    )
  end

  it 'uses ruby 1.9 syntax with global config' do
    temp_parser_version = Imagen.parser_version
    Imagen.parser_version = 'ruby19'

    parser = described_class.new

    expect { parser.parse(ruby20) }.to raise_error(
      Parser::SyntaxError,
      'unexpected token tLABEL'
    )
    Imagen.parser_version = temp_parser_version
  end

  it 'fails on unknown syntax version string' do
    expect { described_class.new('jruby') }.to raise_error(
      ArgumentError,
      'jruby is not supported by imagen'
    )
  end

  it 'uses a current ruby (> 2) by default' do
    parser = described_class.new
    expect { parser.parse(ruby20) }.not_to raise_error
  end
end
