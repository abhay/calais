require File.expand_path("#{File.dirname(__FILE__)}/helper")

describe Calais do
  it "provides a version number" do
    Calais::VERSION.should_not be_nil
  end
end

describe Calais, ".new" do
  it "accepts arguments as a hash" do
    client = nil
    
    lambda { client = Calais.new(:content => SAMPLE_DOCUMENT) }.should_not raise_error(ArgumentError)

    client.license_id.should == LICENSE_KEY
    client.content.should == SAMPLE_DOCUMENT
  end
  
  it "accepts arguments as a block" do
    client = nil
    
    lambda {
      client = Calais.new do |c|
        c.content = SAMPLE_DOCUMENT
      end
    }.should_not raise_error(ArgumentError)

    client.license_id.should == LICENSE_KEY
    client.content.should == SAMPLE_DOCUMENT
  end
  
  it "should not accept unkonwn attributes" do
    lambda { Calais.new(:monkey => "monkey") }.should raise_error(NoMethodError)
  end
end

describe Calais, ".enlighten" do
  before(:all) do
    @marked = Calais.enlighten(:content => SAMPLE_DOCUMENT, :content_type => :xml)
  end
  
  it "returns a string" do
    @marked.should_not be_nil
    @marked.should be_a_kind_of(String)
  end
end

describe Calais, ".call" do
  before(:all) do
    @client = Calais.new(:content => SAMPLE_DOCUMENT)
  end

  it "accepts known methods" do
    lambda { @client.call('enlighten') }.should_not raise_error(ArgumentError)
  end

  it "complains about unkown methods" do
    lambda { @client.call('monkey') }.should raise_error(ArgumentError)
  end
end

describe Calais, ".params_xml" do
  it "returns an xml encoded string" do
    client = Calais.new(:content => SAMPLE_DOCUMENT, :content_type => :xml)
    client.send("params_xml").should_not be_nil
    client.send("params_xml").should == %[<c:params xmlns:c=\"http://s.opencalais.com/1/pred/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"><c:processingDirectives c:contentType=\"TEXT/XML\" c:outputFormat=\"XML/RDF\"></c:processingDirectives><c:userDirectives c:allowDistribution=\"false\" c:allowSearch=\"false\" c:externalID=\"dc68d5a382724c2238d9f22ba9c0b4d2581569d8\" c:submitter=\"calais.rb\"></c:userDirectives><c:externalMetadata></c:externalMetadata></c:params>]
  end
end