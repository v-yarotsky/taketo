require 'spec_helper'

module Taketo::ConfigVisitors

  describe BaseVisitor do
    class DummyVisitor < BaseVisitor
      visit String do |s|
        s.upcase
      end

      visit NilClass do |n|
        "hooray"
      end

      visit Fixnum do |n|
        n.to_s.reverse
      end

      visit Numeric do |n|
        n.to_s
      end

      after_visit Numeric do |n|
        n * 2
      end
    end

    subject(:visitor) { DummyVisitor.new }

    it "defines #visit* methods" do
      expect(visitor.visit_string('qwe')).to eq('QWE')
      expect(visitor.visit_nil_class(nil)).to eq('hooray')
    end

    it "dispatches according to class" do
      expect(visitor.visit(700)).to eq("007")
    end

    it "takes ancestors into account" do
      expect(visitor.visit(2.0)).to eq("2.0")
    end

    it "skips anonymous classes/modules" do
      c = Class.new(Numeric) do
        def to_s; "captured as Numeric"; end
      end
      expect(visitor.visit(c.new)).to eq("captured as Numeric")
    end

    it "defines #after_visit* methods" do
      expect(visitor.after_visit_numeric(42)).to eq(84)
    end
  end

end
