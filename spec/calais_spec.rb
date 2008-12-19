require File.join(File.dirname(__FILE__), %w[helper])
require File.join(File.dirname(__FILE__), "calais/client_spec")
require File.join(File.dirname(__FILE__), "calais/response_spec")

describe Calais do
  it "provides a version number" do
    Calais::VERSION.should_not be_nil
  end
end