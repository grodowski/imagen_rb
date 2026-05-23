# frozen_string_literal: true

describe Imagen::AST::Parser do
  let(:ruby33_syntax) do
    <<-CODE
      [1, 2, 3] => [Integer => a, *]
      a
    CODE
  end

  it 'parses ruby 3.3 syntax with ruby33 version' do
    parser = described_class.new('ruby33')
    expect { parser.parse(ruby33_syntax) }.not_to raise_error
  end

  it 'parses ruby 3.3 syntax with global config' do
    temp_parser_version = Imagen.parser_version
    Imagen.parser_version = 'ruby33'

    parser = described_class.new

    expect { parser.parse(ruby33_syntax) }.not_to raise_error
    Imagen.parser_version = temp_parser_version
  end

  it 'fails on unknown syntax version string' do
    expect { described_class.new('jruby') }.to raise_error(
      ArgumentError,
      'jruby is not supported by imagen'
    )
  end

  it 'fails on pre-3.3 version strings' do
    expect { described_class.new('ruby19') }.to raise_error(
      ArgumentError,
      'ruby19 is not supported by imagen'
    )
  end

  it 'uses the current ruby version by default' do
    parser = described_class.new
    expect { parser.parse(ruby33_syntax) }.not_to raise_error
  end
end
