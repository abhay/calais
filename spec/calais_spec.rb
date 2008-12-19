require File.join(File.dirname(__FILE__), %w[helper])

describe Calais do
  it "provides a version number" do
    Calais::VERSION.should_not be_nil
  end
end