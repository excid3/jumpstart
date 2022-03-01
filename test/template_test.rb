require "minitest/autorun"

class TemplateTest < Minitest::Test
  def setup
    system("[ -d test_app ] && rm -rf test_app")
    system("git config --global init.defaultBranch main")
  end

  def teardown
    setup
  end

  def test_generator_succeeds_with_default_database
    output, err = capture_subprocess_io do
      system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app -m template.rb")
    end
    assert_nil err
    assert_includes output, "Jumpstart app successfully created!"
  end

  def test_generator_with_postgres_succeeds
    output, err = capture_subprocess_io do
      system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app -m template.rb -d postgresql")
    end
    assert_nil err
    assert_includes output, "Jumpstart app successfully created!"
  end

  def test_generator_with_mysql_succeeds
    output, err = capture_subprocess_io do
      system("DISABLE_SPRING=1 SKIP_GIT=1 rails new test_app -m template.rb -d mysql")
    end
    assert_nil err
    assert_includes output, "Jumpstart app successfully created!"
  end
end
