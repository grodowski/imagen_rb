# frozen_string_literal: true

require 'spec_helper'

require 'undercover'

require 'pry'

describe Undercover::Changeset do
  it 'diffs index and staging area against HEAD' do
    changeset = Undercover::Changeset.new('spec/undercover_fixtures').update

    expect(changeset.files.keys.sort).to eq(%w[file_one file_two staged_file])
  end

  it 'has all the changes agains base with compare_base arg' do
    changeset = Undercover::Changeset.new(
      'spec/undercover_fixtures',
      'master'
    ).update

    expect(changeset.files.keys.sort).to eq(
      %w[file_one file_three file_two staged_file]
    )
  end
end
