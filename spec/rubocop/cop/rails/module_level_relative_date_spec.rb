# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ModuleLevelRelativeDate, :config do
  context 'passed to a dsl method' do
    it 'registers an offense for ActiveSupport::Time.zone.now' do
      offensive_code = <<~RUBY
        class SomeClass
          validates_comparison_of :published_at, less_than: Time.zone.now 
                                                            ^^^^^^^^^^^^^ Do not use `%<method_name>s` at the module level as it will be evaluated only once.
        end
      RUBY
      expect_offense(offensive_code)
    end
  end

  context 'assigned to a constant' do
    it 'registers an offense for ActiveSupport::Time.zone.now' do
      expect_offense(<<~RUBY)
        class SomeClass
          TODAY = Time.zone.now
                  ^^^^^^^^^^^^^ Do not use `%<method_name>s` at the module level as it will be evaluated only once.
        end
      RUBY
    end
  end

  context 'assigned to a global variable' do
    it 'registers an offense for ActiveSupport::Time.zone.now' do
      expect_offense(<<~RUBY)
        class SomeClass
          @@today = Time.zone.now
                    ^^^^^^^^^^^^^ Do not use `%<method_name>s` at the module level as it will be evaluated only once.
        end
      RUBY
    end
  end

  context 'within a method' do
    it 'allows ActiveSupport calls within methods' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          def legal_method
            Time.zone.now 
          end
        end
      RUBY
    end
  end

  context 'assigning to a global variable' do
    it 'is fine with it if there is a lambda' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          @@today = -> { Time.zone.now }
        end
      RUBY
    end
  end

  context 'within a proc' do
    it 'allows ActiveSupport calls within blocks' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          validates_comparison_of :published_at, less_than: -> { Time.zone.now }
        end
      RUBY
    end
  end

  context 'within a module' do
    it 'allows ActiveSupport calls within blocks' do
      expect_no_offenses(<<~RUBY)
        module SomeModule
          validates_comparison_of :published_at, less_than: -> { Time.zone.now }
        end
      RUBY
    end
  end
end
