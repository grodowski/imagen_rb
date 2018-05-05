# frozen_string_literal: true

require 'spec_helper'

describe Undercover::CLI do
  it 'creates an Undercover::Report with defaults' do
    expect(Undercover::Report)
      .to receive(:new)
      .with(a_string_ending_with('coverage/lcov/imagen-rb.lcov'), '.', '.git')
    subject.run
  end

  it 'creates an Undercover::Report with options' do
    expect(Undercover::Report)
      .to receive(:new)
      .with('custom-dir/custom-lcov', 'subproject/custom-dir', '.git')
    subject.run(%w[--lcov=custom-dir/custom-lcov --path=subproject/custom-dir])
  end

  xit 'returns 0 exit code on success' do
  end

  xit 'returns 1 exit code on success' do
  end
end
