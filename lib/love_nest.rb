module LoveNest
  module TestCase
    def self.included(base) #:nodoc:
      base.extend ClassMethods
      base.instance_variable_set(:@__test_name_prefix, "")
    end

    module ClassMethods
      # Define a <tt>setup</tt> method to run before each of your tests.
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       setup do
      #         super
      #         @foo = Foo.new
      #       end
      #
      #       ...
      #     end
      def setup(&block)
        include LoveNest.module_with_callback(:setup, &block)
      end
      alias_method :before, :setup

      # Define a <tt>teardown</tt> method to run after each of your tests.
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       teardown do
      #         super
      #         @foo = nil
      #       end
      #
      #       ...
      #     end
      def teardown(&block)
        include LoveNest.module_with_callback(:teardown, &block)
      end
      alias_method :after, :teardown

      # Define a <tt>setup</tt> method that will run <b>only once</b> for this
      # test case (ie, before <b>all</b> tests in this class/context).
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       global_setup do
      #         super
      #         FileUtils.mkdir_p "some_dir"
      #       end
      #
      #       ...
      #     end
      #
      # Most of the times, calling this method is a testing smell, since you
      # shouldn't have complicated setups when testing. But it has some real
      # uses. Just use with caution.
      def global_setup(&block)
        include LoveNest.module_with_callback(:global_setup, &block)
      end
      alias_method :before_all, :global_setup

      # Define a <tt>teardown</tt> method that will run <b>only once</b> for 
      # this test case (ie, after <b>all</b> tests in this class/context).
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       global_teardown do
      #         super
      #         FileUtils.rm_rf "some_dir"
      #       end
      #
      #       ...
      #     end
      #
      # Most of the times, calling this method is a testing smell, since you
      # shouldn't have complicated cleanups when testing. But it has some real
      # uses. Just use with caution.
      def global_teardown(&block)
        include LoveNest.module_with_callback(:global_teardown, &block)
      end
      alias_method :after_all, :global_teardown

      # Define a LoveNested <tt>context</tt> in this test case. This allows you
      # to group related tests.
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       context "A foo" do
      #         setup do
      #           super
      #           @foo = Foo.new
      #         end
      #
      #         test "is fooey" do
      #           assert @foo.fooey?
      #         end
      #       end
      #
      #       context "A bar" do
      #         ...
      #       end
      #     end
      #
      # <tt>setup</tt>/<tt>teardown</tt> blocks defined in "parent" contexts
      # will be run too.
      def context(name, &declaration)
        name = "#{@__test_name_prefix} #{name}"
        context = Class.new(self)
        context.instance_variable_set(:@__test_name_prefix, name)
        context.class_eval(&declaration)
      end

      # Define a test with a "prettier" name than by doing `def test_foo_bar`
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       test "a duck cuacks" do
      #         assert Duck.new.respond_to?(:cuack)
      #       end
      #     end
      #
      # This would be the same as defining a method named `test_a_duck_cuacks`.
      # If you are within a <tt>context</tt>, then the context name gets
      # prefixed into the test name:
      #
      #     class SomeTest < Test::Unit::TestCase
      #       include LoveNest::TestCase
      #
      #       context "A Duck" do
      #         setup do
      #           super
      #           @duck = Duck.new
      #         end
      #
      #         test "knows how to cuack" do
      #           assert @duck.respond_to?(:cuack)
      #         end
      #       end
      #     end
      #
      # This will define a method `test_a_duck_knows_how_to_cuack`.
      def test(name, &declaration)
        name = "test_#{@__test_name_prefix}_#{name}".downcase.gsub(/\W+/, "_")
        define_method(name, &declaration)
      end
      alias_method :it, :test
    end

    def setup #:nodoc:
      unless @__global_setup_run
        @__global_setup_run = true
        global_setup
      end
    end

    def teardown #:nodoc:
      unless @__global_teardown_run
        @__global_teardown_run = true
        global_teardown
      end
    end

    def global_setup #:nodoc:
    end

    def global_teardown #:nodoc:
    end
  end

  def self.module_with_callback(name, &declaration) #:nodoc:
    Module.new { define_method(name, &declaration) }
  end
end
