require 'spec_helper'

describe Ruleset do
  it 'has a version number' do
    expect(Ruleset::VERSION).not_to be nil
  end

  describe Ruleset::SelfEvaluatingRule do
    describe "#evalute" do
      # An example rule on whether to include a link to an external service:
      #   1) user is a type 123
      #   2) header is not xyz company
      #   3) no errors from external service link generator
      let(:user)    { "mock-user" }
      let(:header)  { "mock-header" }
      let(:service) { "mock-service" }
      let(:user_123_type)      { Ruleset::UnaryTerm.new(user, :t123?) }
      let(:header_xyz_company) { Ruleset::UnaryTerm.new(header, :xyz?) }
      let(:errors_check)       { Ruleset::UnaryTerm.new(service, :include_link?) }
      let(:example_rule) do
        sub_term =  Ruleset::KeyWordTerm.new(user_123_type, :&, :header_xyz_company)
        root_term = Ruleset::KeyWordTerm.new(sub_term, :&, :errors_check)
        rule = Ruleset::SelfEvaluatingRule.new(root_term)
      end
      before do
        allow(user)   .to receive(:t123?)        .and_return(true)
        allow(header) .to receive(:xyz?)         .and_return(false)
        allow(service).to receive(:include_link?).and_return(true)
      end
      it "will evaluate the rule and return true/false" do
        expect(example_rule.evaluate).to eq true
      end
    end
  end

  describe Ruleset::Constant do
    describe "#resolve" do
      it "returns the constant's initialized value" do
        expect(Ruleset::Constant.new("abcd").resolve).to eq "abcd"
        expect(Ruleset::Constant.new(33).resolve).to eq 33
        expect(Ruleset::Constant.new(false).resolve).to eq false
      end
    end
  end

  describe Ruleset::UnaryTerm do
    let(:a_object) do
      Object.new.tap do |obj|
        obj.define_singleton_method(:a_method) do
            "a message from a"
        end
      end
    end
    let(:b_object) do
      Object.new.tap do |obj|
        obj.define_singleton_method(:b_method) do
            "be a message from b"
        end
      end
    end
    describe "#resolve" do
      it "returns the return of the given message sent to the given object" do
        a_rule = Ruleset::UnaryTerm.new(a_object, :a_method)
        b_rule = Ruleset::UnaryTerm.new(b_object, :b_method)
        expect(a_rule.resolve).to eq "a message from a"
        expect(b_rule.resolve).to eq "be a message from b"
      end
    end
  end

  describe Ruleset::BinaryTerm do
    let(:a_string) { "Ho! " }
    describe "#resolve" do
      it "returns the result of calling the method on the object with the given arguments" do
        rule = Ruleset::BinaryTerm.new(a_string, :*, 3)
        expect(rule.resolve).to eq "Ho! Ho! Ho! "
      end
    end
  end
end
