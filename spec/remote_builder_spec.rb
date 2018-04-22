# frozen_string_literal: true

require 'spec_helper'

describe Imagen do
  let(:repo_url) { 'https://github.com/not-existent/bacon' }
  let(:expect_clone) { expect(Imagen::Clone).to receive(:perform) }

  subject { Imagen::RemoteBuilder.new(repo_url) }

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

    it 'builds a tree with correct node types (integrated)' do
      root = subject.build
      expect(root).to be_a(Imagen::Node::Root)

      classes = root.find_all(of_type(Imagen::Node::Class))
      expect(classes.map(&:name)).to include('BaconClass', 'BaconChildClass')

      modules = root.find_all(of_type(Imagen::Node::Module))
      expect(modules.map(&:name)).to include('BaconModule')

      imethods = root.find_all(of_type(Imagen::Node::IMethod))
      expect(imethods.map(&:name))
        .to include('foo', 'foo_child', 'lonely_method', 'bar')

      cmethods = root.find_all(of_type(Imagen::Node::CMethod))
      expect(cmethods.map(&:name)).to include('foo', 'bar')
    end
  end
end
