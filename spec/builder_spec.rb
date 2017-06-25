# frozen_string_literal: true

require 'rspec'
require 'imagen'

describe Imagen::Builder do
  let(:repo_url) { 'https://github.com/not-existent/bacon' }
  let(:expect_clone) { expect(Imagen::Clone).to receive(:perform) }

  subject { Imagen::Builder.new(repo_url) }

  it 'calls Clone with repo_url and tempdir' do
    expect_clone.with(repo_url, subject.dir)
    subject.build
  end

  it 'deletes the tempdir' do
    expect_clone
    expect { subject.build }
      .to change { Dir.exist?(subject.dir) }
      .from(true).to(false)
  end

  context 'given an existing clone dir' do
    before do
      expect_clone
      allow(Dir).to receive(:mktmpdir) { 'spec/fixtures' }
      allow(FileUtils).to receive(:remove_entry) # do not remove spec/fixtures
    end

    it 'builds a tree' do
      expect(subject.build).to be_a(Imagen::Node::Root)
    end
  end # end context 'given a clone dir'
end
