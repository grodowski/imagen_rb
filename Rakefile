# frozen_string_literal: true

$LOAD_PATH << 'lib'

require 'rubocop/rake_task'
require 'rake/testtask'

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop)

desc 'Run Tests'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

task default: %i[rubocop test]
