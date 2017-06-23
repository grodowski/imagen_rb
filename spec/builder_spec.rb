# frozen_string_literal: true

require 'rspec'
require 'imagen'

describe Imagen::Builder do
  let(:repo_url) { 'https://github.com/grodowski/imagen-rb' }
  subject { Imagen::Builder.new(repo_url) }

  it 'calls Clone with repo_url and tempdir' do
    expect(Imagen::Clone).to receive(:perform).with(repo_url, subject.dir)
    subject.build
  end

  # TODO: this is a veery slow test. Use fakefs?
  it 'deletes the tempdir' do
    expect { subject.build }
      .to change { Dir.exist?(subject.dir) }
      .from(true).to(false)
  end
end
