# frozen_string_literal: true

require 'minitest/autorun'
require 'imagen'

class ImagenTest < Minitest::Test
  def setup
    # TODO: add setup
  end

  def test_returns_repo_url_dummy
    assert_equal 'git@bacon', Imagen::Builder.build('git@bacon')
  end
end
