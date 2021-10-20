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
      system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app -m template.rb --skip-javascript")
    end
    assert_includes output, "Jumpstart app successfully created!"
  end

  def test_apply_template_succeeds
    output, _err = capture_subprocess_io do
      system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app --skip-javascript")
      system("cd test_app && rails app:template LOCATION=../template.rb")
    end
    assert_includes output, "Jumpstart app successfully created!"
  end

  # TODO: Fix these tests on CI so they don't fail on db:create
  #
  # def test_generator_with_postgres_succeeds
  #   output, err = capture_subprocess_io do
  #     system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app -m template.rb -d postgresql")
  #   end
  #   assert_includes output, "Jumpstart app successfully created!"
  # end

  # def test_generator_with_mysql_succeeds
  #   output, err = capture_subprocess_io do
  #     system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app -m template.rb -d mysql")
  #   end
  #   assert_includes output, "Jumpstart app successfully created!"
  # end
end
