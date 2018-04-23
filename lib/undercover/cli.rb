# frozen_string_literal: true

require 'undercover'

module Undercover
  class CLI
    # TODO: add executable in ./bin later
    def run(args = ARGV)
      puts "hello from executable with #{args}"

      require 'pry'
      binding.pry

      0
    end
  end
end