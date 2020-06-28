require "minitest/autorun"

class TemplateTest < Minitest::Test
  def setup
    system("[ -d test_app ] && rm -rf test_app")
  end

  def teardown
    setup
  end

  def test_generator_succeeds
    output, err = capture_subprocess_io do
      system("DISABLE_SPRING=1 SKIP_GIT=1 rails new -m template.rb test_app")
    end
    assert_includes output, "Jumpstart app successfully created!"
  end
end
