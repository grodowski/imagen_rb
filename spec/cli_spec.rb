# frozen_string_literal: true

require 'spec_helper'

describe Undercover::CLI do
  it 'creates an Undercover::Report with defaults' do
    stub_build
    expect(Undercover::Report)
      .to receive(:new)
      .with(
        a_string_ending_with('coverage/lcov/imagen-rb.lcov'),
        '.',
        git_dir: '.git',
        compare: nil
      )
      .and_call_original
    subject.run
  end

  it 'creates an Undercover::Report with options' do
    stub_build
    expect(Undercover::Report)
      .to receive(:new)
      .with(
        'spec/fixtures/sample.lcov',
        'spec/fixtures',
        git_dir: 'test.git',
        compare: nil
      )
      .and_call_original
    subject.run(%w[-lspec/fixtures/sample.lcov -pspec/fixtures -gtest.git])
  end

  it 'accepts --compare' do
    stub_build
    expect(Undercover::Report)
      .to receive(:new)
      .with(
        a_string_ending_with('coverage/lcov/imagen-rb.lcov'),
        '.',
        git_dir: '.git',
        compare: 'master'
      )
      .and_call_original
    subject.run(%w[-cmaster])
  end

  it 'returns 0 exit code on success' do
    mock_report = instance_double(Undercover::Report)
    stub_build.and_return(mock_report)

    expect(mock_report).to receive(:build_warnings) { [] }
    expect(subject.run).to eq(0)
  end

  it 'returns 1 exit code on warnings' do
    mock_report = instance_double(Undercover::Report)
    stub_build.and_return(mock_report)

    allow(Undercover::Formatter).to receive(:new)

    expect(mock_report).to receive(:build_warnings) { [double] }
    expect(subject.run).to eq(1)
  end

  def stub_build
    allow_any_instance_of(Undercover::Report).to receive(:build) { |rep| rep }
  end
end
