require 'spec_helper'
require 'taketo/config_visitor'

include Taketo

describe "ConfigVisitor" do
  class DummyVisitor < ConfigVisitor
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

  it "raises if doesn't know how to visit" do
    expect { visitor.visit([]) }.to raise_error /Array/
  end
end

