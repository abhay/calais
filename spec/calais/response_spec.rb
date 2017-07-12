require File.join(File.dirname(__FILE__), %w[.. helper])

describe Calais::Response, :new do
  it 'accepts an rdf string to generate the response object' do
    expect(lambda { Calais::Response.new(SAMPLE_RESPONSE) }).not_to raise_error
  end
end

describe Calais::Response, :new do
  it "should return error message in runtime error" do
    expect(
      lambda {@response = Calais::Response.new(RESPONSE_WITH_EXCEPTION)}
    ).to raise_error(Calais::Error, "My Error Message")
  end
end

describe Calais::Response, :new do
  before :all do
    @response = Calais::Response.new(SAMPLE_RESPONSE)
  end

  it 'should extract document information' do
    expect(@response.language).to eq('English')
    expect(@response.submission_date).to be_a_kind_of(DateTime)
    expect(@response.signature).to be_a_kind_of(String)
    expect(@response.submitter_code).to be_a_kind_of(String)
    expect(@response.request_id).to be_a_kind_of(String)
    expect(@response.doc_title).to eq('Record number of bicycles sold in Australia in 2006')
    expect(@response.doc_date).to be_a_kind_of(Date)
  end

  it 'should extract entities' do
    entities = @response.entities
    expect(entities.map { |e| e.type }.sort.uniq).to eq(%w[City Continent Country IndustryTerm Organization Person Position ProvinceOrState])
  end

  it 'should extract relations' do
    relations = @response.relations
    expect(relations.map { |e| e.type }.sort.uniq).to eq(%w[GenericRelations PersonAttributes PersonCareer Quotation])
  end

  describe 'geographies' do
    it 'should be extracted' do
      geographies = @response.geographies
      expect(geographies.map { |e| e.name }.sort.uniq).to eq(%w[Australia Hobart,Tasmania,Australia Tasmania,Australia])
    end

    it 'should have relevance' do
      geographies = @response.geographies
      geographies.map { |e| e.relevance }.length >= 1
    end

    it 'should have relevance value' do
      geographies = @response.geographies
      expect(geographies.map { |e| e.relevance }.sort.uniq).to eq([0.168, 0.718])
    end
  end

  it 'should extract relevances' do
    expect(@response.instance_variable_get(:@relevances)).to be_a_kind_of(Hash)
  end

  it 'should assign a floating-point relevance to each entity' do
    @response.entities.each do |e|
      expect(e.relevance).to be_a_kind_of(Float)
    end
  end

  it 'should find the correct document categories returned by OpenCalais' do
    expect(@response.categories.map {|c| c.name }.sort).to eq(%w[Business_Finance Technology_Internet])
  end

  it 'should find the correct document category scores returned by OpenCalais' do
    @response.categories.map do |c|
      expect(c.score).to be_a_kind_of(Float)
    end
  end

  it "should not raise an error if no score is given by OpenCalais" do
    expect(
      lambda {Calais::Response.new(SAMPLE_RESPONSE_WITH_NO_SCORE)}
    ).not_to raise_error
  end

  it "should not raise an error if no score is given by OpenCalais" do
    response = Calais::Response.new(SAMPLE_RESPONSE_WITH_NO_SCORE)
    expect(response.categories.map {|c| c.score }).to eq([nil])
  end

  it 'should find social tags' do
    expect(@response.socialtags.map {|c| c.name }.sort).to eq(["Appropriate technology", "Bicycles", "Business_Finance", "Cycling", "Motorized bicycle", "Recreation", "Sustainability", "Sustainable transport", "Technology_Internet"])
  end

  it 'should have important scores associated with social tags' do
    @response.socialtags.map {|c| expect(c.importance).to be_a_kind_of(Integer) }
  end


  it 'should find instances for each entity' do
    @response.entities.each {|e|
      expect(e.instances.size).to be > 0
    }
  end


  it 'should find instances for each relation' do
    @response.relations.each {|r|
      expect(r.instances.size).to be > 0
    }
  end

  it 'should find the correct instances for each entity' do
    ## This currently tests only for the "Australia" entity's
    ## instances.  A more thorough test that tests for the instances
    ## of each of the many entities in the sample doc is desirable in
    ## the future.

    australia = @response.entities.select {|e| e.attributes["name"] == "Australia" }.first
    expect(australia.instances.size).to eq(3)
    instances = australia.instances.sort{|a,b| a.offset <=> b.offset }

    expect(instances[0].prefix).to eq("number of bicycles sold in ")
    expect(instances[0].exact).to eq("Australia")
    expect(instances[0].suffix).to eq(" in 2006<\/title>\n<date>January 4,")
    expect(instances[0].offset).to eq(67)
    expect(instances[0].length).to eq(9)

    expect(instances[1].prefix).to eq("4, 2007<\/date>\n<body>\nBicycle sales in ")
    expect(instances[1].exact).to eq("Australia")
    expect(instances[1].suffix).to eq(" have recorded record sales of 1,273,781 units")
    expect(instances[1].offset).to eq(146)
    expect(instances[1].length).to eq(9)

    expect(instances[2].prefix).to eq(" the traditional company car,\" he said.\n\n\"Some of ")
    expect(instances[2].exact).to eq("Australia")
    expect(instances[2].suffix).to eq("'s biggest corporations now have bicycle fleets,")
    expect(instances[2].offset).to eq(952)
    expect(instances[2].length).to eq(9)
  end

  it 'should find the correct instances for each relation' do
    ## This currently tests only for one relation's instances.  A more
    ## thorough test that tests for the instances of each of the many other
    ## relations in the sample doc is desirable in the future.

    rel = @response.relations.select {|e| e.calais_hash.value == "8f3936d9-cf6b-37fc-ae0d-a145959ae3b5" }.first
    expect(rel.instances.size).to eq(1)

    expect(rel.instances.first.prefix).to eq(" manufacturers.\n\nThe Cycling Promotion Fund (CPF) ")
    expect(rel.instances.first.exact).to eq("spokesman Ian Christie said Australians were increasingly using bicycles as an alternative to cars.")
    expect(rel.instances.first.suffix).to eq(" Sales rose nine percent in 2006 while the car")
    expect(rel.instances.first.offset).to eq(425)
    expect(rel.instances.first.length).to eq(99)
  end
end
