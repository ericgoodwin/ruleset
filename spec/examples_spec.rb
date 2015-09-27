require 'spec_helper'

describe Ruleset do
  # An example rule on whether to include a link to an external service:
  #   1) user is a type 123
  #   2) header is not xyz company
  #   3) no errors from external service link generator
  let(:xyz_result)         { false }
  let(:user)               { "mock-user" }
  let(:header)             { "mock-header" }
  let(:service)            { "mock-service" }
  let(:type_123)           { Ruleset::UnaryTerm.new(user, :t123?) }
  let(:header_xyz_company) { Ruleset::UnaryTerm.new(header, :xyz?) }
  let(:no_errors)          { Ruleset::UnaryTerm.new(service, :include_link?) }
  let(:not_xyz)            { Ruleset::BinaryTerm.new(header_xyz_company, :==, false) }
  before do
    expect(user)   .to receive(:t123?)        .and_return(true)
    expect(header) .to receive(:xyz?)         .and_return(xyz_result)
    expect(service).to receive(:include_link?).and_return(true)
  end

  describe Ruleset::Ruleset do
    describe "#evaluate" do
      let(:rules) { [type_123, not_xyz, no_errors] }
      subject { Ruleset::Ruleset.new(*rules).evaluate }
      it { is_expected.to eq true }

      context "when a rule is not true" do
        let(:xyz_result) { true }
        it { is_expected.to eq false }
      end
    end
  end

  describe Ruleset::SelfEvaluatingRule do
    describe "#evaluate" do
      subject do
        sub_term  = Ruleset::BinaryTerm.new(type_123, :&, not_xyz)
        root_term = Ruleset::BinaryTerm.new(sub_term, :&, no_errors)
        Ruleset::SelfEvaluatingRule.new(root_term)
      end
      it "will evaluate the rule and return its result" do
        expect(subject.evaluate).to eq true
      end

      context "when something is not right" do
        let(:xyz_result) { true }
        it "will evaluate the rule and return its result" do
          expect(subject.evaluate).to eq false
        end
      end
    end
  end
end
