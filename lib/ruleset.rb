require "ruleset/version"
require "pry"

module Ruleset
  class SelfEvaluatingRule
    def initialize(root_term, arguments = {})
      @arguments = arguments
      @root_term = root_term
    end

    def evaluate
      root_term.resolve
    end

    def evaluate_with_arguments(arguments = {})
      @arguments = arguments
      evaluate
    end

    def resolve
      evaluate
    end

    private
    attr_reader :arguments, :root_term
  end

  class Term
    def resolve
      raise NotImplementedError
    end
  end

  class UnaryTerm < Term
    def initialize(receiver, operator)
      @receiver = receiver
      @operator = operator
    end

    def resolve
      receiver.send(operator)
    end

    private
    attr_reader :receiver, :operator
  end

  class BinaryTerm < Term
    def initialize(receiver, operator, argument)
      @receiver = receiver
      @operator = operator
      @argument = argument
    end

    def resolve
      @receiver = receiver.resolve if receiver.is_a? Term
      outcome = receiver.send(operator, argument)
      outcome.is_a?(Term) ? outcome.resolve : outcome
    end

    private
    attr_reader :receiver, :operator, :argument
  end

  class KeyWordTerm < Term
    def initialize(receiver, operator, *arguments)
      @receiver = receiver
      @operator = operator
      @arguments = arguments
    end

    def resolve
      @receiver = receiver.resolve if receiver.is_a? Term
      @arguments = arguments.each do |arg|
        arg.is_a?(Term) ? arg.resolve : arg
      end
      outcome = receiver.send(operator, *arguments)
      outcome.is_a?(Term) ? outcome.resolve : outcome
    end

    private
    attr_reader :receiver, :operator, :arguments
  end

  class Variable < Term
    def initialize(source, getterMessage)
      @source = source
      @getterMessage = getterMessage
    end

    def resolve
      instantiate
    end

    def instantiate
      (source.instantiate).send(getterMessage).instantiate
    end

    private
    attr_reader :source, :getterMessage
  end

  class Constant < Term
    def initialize(value)
      @value = value
    end

    def resolve
      value
    end

    private
    attr_reader :value
  end
end
