# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks if a relative date call occurs at the class or module level.
      # Relative date calls at the class or module level will only be executed once.
      # The dates returned will be preserved until the class or module is reloaded.
      #
      # @safety
      #   This cop is unsafe, because a refactor will be required to move the
      # relative date call to a method or proc.
      #
      # @example
      #   # bad
      #   validates :start_at, comparison: { start_at: Time.zone.now }
      #
      #   # bad
      #   TODAY = Time.zone.now
      #
      #   # bad
      #   @@today = Time.zone.now
      #
      #   # good
      #   validates :start_at, comparison: { start_at: -> { Time.zone.now } }
      #
      #   # good
      #   def today
      #     Time.zone.now
      #   end
      #
      #   # good
      #   @@today = -> { Time.zone.today }
      #
      # TODO: Better Error Message (see method_name in RelativeDateConstant)
      class ModuleLevelRelativeDate < Base
        MSG = 'Do not use `%<method_name>s` at the module level as it will be evaluated only once.'
        RELATIVE_DATE_METHODS = %i[now since from_now after ago until before yesterday tomorrow].to_set.freeze
        # Only pass RELATIVE_DATE_METHODS to on_send
        RESTRICT_ON_SEND = RELATIVE_DATE_METHODS
        GOOD_SCOPE_NODES = %i[def block].freeze # immediately execute
        BAD_SCOPE_NODES = %i[class module].freeze # execute on class load
        SCOPE_NODES = GOOD_SCOPE_NODES + BAD_SCOPE_NODES

        # Matches all relative date functions
        # def_node_matcher :relative_date?, <<~PATTERN
        #   (send _ $RELATIVE_DATE_METHODS)
        # PATTERN

        def on_send(node)
          parent_scope_node = (node.ancestors.map(&:type) & SCOPE_NODES).first
          return if GOOD_SCOPE_NODES.include?(parent_scope_node)

          add_offense(node)
        end
      end
    end
  end
end
