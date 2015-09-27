require 'spec_helper'

describe Ruleset do
  it 'has a version number' do
    expect(Ruleset::VERSION).not_to be nil
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

      context "when receiver is also a term" do
        let(:constant) { Ruleset::Constant.new("here I am") }
        subject { Ruleset::BinaryTerm.new(constant, :delete, "am") }
        it "will resolve the rule before calling the operator" do
          expect(subject.resolve).to eq "here I "
        end
      end

      context "when the argument is also a term" do
        let(:constant) { Ruleset::Constant.new("am") }
        subject { Ruleset::BinaryTerm.new("here I am", :delete, constant) }
        it "will resolve the argument before calling the operator" do
          expect(subject.resolve).to eq "here I "
        end
      end

      context "when result of resolving is a term" do
        let(:redirection) { Ruleset::Constant.new("here I am") }
        subject           { Ruleset::BinaryTerm.new({key: redirection}, :fetch, :key) }
        it "will resolve the term before returning" do
          expect(subject.resolve).to eq "here I am"
        end
      end
    end
  end

  describe Ruleset::KeyWordTerm do
    describe "#resolve" do
      context "when the arguments are also terms" do
        let(:l) { Ruleset::Constant.new("l") }
        let(:lo) { Ruleset::Constant.new("lo") }
        subject { Ruleset::KeyWordTerm.new("hello", :delete, l, lo) }
        it "will resolve them before calling the operator" do
          expect(subject.resolve).to eq "heo"
        end
      end

      context "when the receiver is a term" do
        let(:constant) { Ruleset::Constant.new("here I am") }
        subject { Ruleset::KeyWordTerm.new(constant, :delete, "am") }
        it "will resolve the rule before call operator" do
          expect(subject.resolve).to eq "here I "
        end
      end
    end
  end
end
