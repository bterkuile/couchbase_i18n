require 'spec_helper'

describe CouchbaseI18n::Store do
  describe "yaml conversion" do
    before :each do
    end

    it "should flatten and indenting reversibility" do
      CouchbaseI18n::Translation.count.should == CouchbaseI18n.traverse_flatten_keys({}, CouchbaseI18n.indent_keys).size
    end
  end
end
