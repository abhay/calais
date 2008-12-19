require File.join(File.dirname(__FILE__), %w[.. helper])

describe Calais::Client, :new do
  it 'accepts arguments as a hash' do
    client = nil

    lambda { client = Calais::Client.new(:content => SAMPLE_DOCUMENT, :license_id => LICENSE_ID) }.should_not raise_error

    client.license_id.should == LICENSE_ID
    client.content.should == SAMPLE_DOCUMENT
  end

  it 'accepts arguments as a block' do
    client = nil

    lambda {
      client = Calais::Client.new do |c|
        c.content = SAMPLE_DOCUMENT
        c.license_id = LICENSE_ID
      end
    }.should_not raise_error

    client.license_id.should == LICENSE_ID
    client.content.should == SAMPLE_DOCUMENT
  end

  it 'should not accept unknown attributes' do
    lambda { Calais::Client.new(:monkey => 'monkey', :license_id => LICENSE_ID) }.should raise_error(NoMethodError)
  end
end

describe Calais::Client, :params_xml do
  it 'returns an xml encoded string' do
    client = Calais::Client.new(:content => SAMPLE_DOCUMENT, :license_id => LICENSE_ID)
    client.params_xml.should == %[<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">\n  <c:processingDirectives/>\n  <c:userDirectives/>\n</c:params>]

    client.content_type = :xml
    client.output_format = :json
    client.reltag_base_url = 'http://opencalais.com'
    client.calculate_relevance = true
    client.metadata_enables = Calais::KNOWN_ENABLES
    client.metadata_discards = Calais::KNOWN_DISCARDS
    client.allow_distribution = true
    client.allow_search = true
    client.external_id = Digest::SHA1.hexdigest(client.content)
    client.submitter = 'calais.rb'

    client.params_xml.should == %[<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">\n  <c:processingDirectives c:contentType="text/xml" c:outputFormat="application/json" c:reltagBaseURL="http://opencalais.com" c:enableMetadataType="GenericRelations" c:discardMetadata="er/Company;er/Geo"/>\n  <c:userDirectives c:allowDistribution="true" c:allowSearch="true" c:externalID="1a008b91e7d21962e132bc1d6cb252532116a606" c:submitter="calais.rb"/>\n</c:params>]
  end
end

describe Calais::Client, :enlighten do
  before do
    @client = Calais::Client.new do |c|
      c.content = SAMPLE_DOCUMENT
      c.license_id = LICENSE_ID
      c.content_type = :xml
      c.output_format = :json
      c.calculate_relevance = true
      c.metadata_enables = Calais::KNOWN_ENABLES
      c.allow_distribution = true
      c.allow_search = true
    end
  end

  it 'provides access to the enlighten command on the generic rest endpoint' do
    @client.should_receive(:do_request).with(anything).and_return(SAMPLE_RESPONSE)
    @client.enlighten
    @client.instance_variable_get(:@client).url.should == Calais::REST_ENDPOINT
  end

  it 'provides access to the enlighten command on the beta rest endpoint' do
    @client.use_beta = true

    @client.should_receive(:do_request).with(anything).and_return(SAMPLE_RESPONSE)
    @client.enlighten
    @client.instance_variable_get(:@client).url.should == Calais::BETA_REST_ENDPOINT
  end
end