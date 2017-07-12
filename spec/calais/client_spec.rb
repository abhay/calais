require File.join(File.dirname(__FILE__), %w[.. helper])

describe Calais::Client, :new do
  it 'accepts arguments as a hash' do
    client = nil

    expect(lambda { client = Calais::Client.new(:content => SAMPLE_DOCUMENT, :license_id => LICENSE_ID) }).not_to raise_error

    expect(client.license_id).to eq(LICENSE_ID)
    expect(client.content).to eq(SAMPLE_DOCUMENT)
  end

  it 'should not accept unknown attributes' do
    expect(lambda { Calais::Client.new(:monkey => 'monkey', :license_id => LICENSE_ID) }).to raise_error(NoMethodError)
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
    end
  end

  it 'provides access to the enlighten command on the generic rest endpoint' do
    @client.should_receive(:do_request).with(anything).and_return(SAMPLE_RESPONSE)
    @client.enlighten
    expect(@client.url).to eq(URI.parse(Calais::REST_ENDPOINT))
  end

  it 'raises an error if there is no license_id' do
    @client.license_id = nil
    expect{ @client.enlighten }.to raise_error("missing license id")
  end

  it 'raises an error if the content_type is not in AVAILABLE_CONTENT_TYPES' do
    @client.content_type = "stuff"
    expect{ @client.enlighten }.to raise_error("unknown content type")
  end

  it 'raises an error if the content_type is not provided' do
    @client.content_type = nil
    expect{ @client.enlighten }.to raise_error("unknown content type")
  end

  it 'raises an error if the content length is less than 1' do
    @client.content = nil
    expect{ @client.enlighten }.to raise_error("missing content")
  end

  it 'raises an error if the content length is greater than 100_000' do
    @client.content = ("b"*100001)
    expect{ @client.enlighten }.to raise_error("content is too large")
  end

  it 'does not require output_format' do
    @client.output_format = nil
    expect{ @client.enlighten }.not_to raise_error
  end

  it 'raises an error if the provided output_format is not in AVAILABLE_OUTPUT_FORMATS' do
    @client.output_format = 'fake'
    expect{ @client.enlighten }.to raise_error("unknown output format")
  end
end
