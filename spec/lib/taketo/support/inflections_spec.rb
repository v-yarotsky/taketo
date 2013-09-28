require 'spec_helper'

include Taketo::Support

describe "Inflections" do
  module Nest1
    module Nest2
      class Thing; end
    end
  end

  describe "#to_singular" do
    it "returns singularized sumbol for klass" do
      expect(Inflections.to_singular(Nest1::Nest2::Thing)).to eq(:thing)
    end

    it "returns singularized sumbol for pluralized symbol" do
      expect(Inflections.to_singular(:things)).to eq(:thing)
    end
  end

  describe "#to_plural" do
    it "returns pluralized sumbol for klass" do
      expect(Inflections.to_plural(Nest1::Nest2::Thing)).to eq(:things)
    end

    it "returns pluralized sumbol for singularized symbol" do
      expect(Inflections.to_plural(:thing)).to eq(:things)
    end
  end

  describe "#to_class" do
    it "returns klass by pluralized symbol" do
      expect(Inflections.to_class(:things, Nest1::Nest2)).to eq(Nest1::Nest2::Thing)
    end

    it "returns klass by singularized symbol" do
      expect(Inflections.to_class(:thing, Nest1::Nest2)).to eq(Nest1::Nest2::Thing)
    end
  end
end


