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

  subject { DummyVisitor.new }

  it "should define #visit* methods" do
    subject.visit_string('qwe').should == 'QWE'
    subject.visit_nil_class(nil).should == 'hooray'
  end

  it "should dispatch according to class" do
    subject.visit(700).should == "007"
  end

  it "should take ancestors into account" do
    subject.visit(2.0).should == "2.0"
  end

  it "should raise if doesn't know how to visit" do
    expect { subject.visit([]) }.to raise_error /Array/
  end
end

