require File.join(File.dirname(__FILE__), %w[.. helper])

describe Calais::Response, :new do
  it 'accepts an rdf string to generate the response object' do
    lambda { Calais::Response.new(SAMPLE_RESPONSE) }.should_not raise_error
  end
end

describe Calais::Response, :new do
  it "should return error message in runtime error" do
    lambda {
      @response = Calais::Response.new(RESPONSE_WITH_EXCEPTION)
    }.should raise_error(Calais::Error, "My Error Message") 
  end
end

describe Calais::Response, :new do
  before :all do
    @response = Calais::Response.new(SAMPLE_RESPONSE)
  end

  it 'should extract document information' do
    @response.language.should == 'English'
    @response.submission_date.should be_a_kind_of(DateTime)
    @response.signature.should be_a_kind_of(String)
    @response.submitter_code.should be_a_kind_of(String)
    @response.request_id.should be_a_kind_of(String)
    @response.doc_title.should == 'Record number of bicycles sold in Australia in 2006'
    @response.doc_date.should be_a_kind_of(Date)
  end

  it 'should extract entities' do
    entities = @response.entities
    entities.map { |e| e.type }.sort.uniq.should == %w[City Continent Country IndustryTerm Organization Person Position ProvinceOrState]
  end

  it 'should extract relations' do
    relations = @response.relations
    relations.map { |e| e.type }.sort.uniq.should == %w[GenericRelations PersonAttributes PersonCareer Quotation]
  end

  describe 'geographies' do
    it 'should be extracted' do
      geographies = @response.geographies
      geographies.map { |e| e.name }.sort.uniq.should == %w[Australia Hobart,Tasmania,Australia Tasmania,Australia]
    end

    it 'should have relevance' do
      geographies = @response.geographies
      geographies.map { |e| e.relevance }.sort.uniq.should be_true
    end

    it 'should have relevance value' do
      geographies = @response.geographies
      geographies.map { |e| e.relevance }.sort.uniq.should == [0.168, 0.718]
    end
  end

  it 'should extract relevances' do
    @response.instance_variable_get(:@relevances).should be_a_kind_of(Hash)
  end

  it 'should assign a floating-point relevance to each entity' do
    @response.entities.each {|e| e.relevance.should be_a_kind_of(Float) }
  end

  it 'should find the correct document categories returned by OpenCalais' do
    @response.categories.map {|c| c.name }.sort.should == %w[Business_Finance Technology_Internet]
  end

  it 'should find the correct document category scores returned by OpenCalais' do
    @response.categories.map {|c| c.score.should be_a_kind_of(Float) }
  end
  
  it "should not raise an error if no score is given by OpenCalais" do
    lambda {Calais::Response.new(SAMPLE_RESPONSE_WITH_NO_SCORE)}.should_not raise_error
  end
  
  it "should not raise an error if no score is given by OpenCalais" do
    response = Calais::Response.new(SAMPLE_RESPONSE_WITH_NO_SCORE)
    response.categories.map {|c| c.score }.should == [nil]
  end
  
  it 'should find social tags' do
    @response.socialtags.map {|c| c.name }.sort.should == ["Appropriate technology", "Bicycles", "Business_Finance", "Cycling", "Motorized bicycle", "Recreation", "Sustainability", "Sustainable transport", "Technology_Internet"]
  end

  it 'should have important scores associated with social tags' do
    @response.socialtags.map {|c| c.importance.should be_a_kind_of(Integer) }
  end
  
  
  it 'should find instances for each entity' do
    @response.entities.each {|e|
      e.instances.size.should > 0
    }
  end


  it 'should find instances for each relation' do
    @response.relations.each {|r|
      r.instances.size.should > 0
    }
  end

  it 'should find the correct instances for each entity' do
    ## This currently tests only for the "Australia" entity's
    ## instances.  A more thorough test that tests for the instances
    ## of each of the many entities in the sample doc is desirable in
    ## the future.

    australia = @response.entities.select {|e| e.attributes["name"] == "Australia" }.first
    australia.instances.size.should == 3
    instances = australia.instances.sort{|a,b| a.offset <=> b.offset }

    instances[0].prefix.should == "number of bicycles sold in "
    instances[0].exact.should == "Australia"
    instances[0].suffix.should == " in 2006<\/title>\n<date>January 4,"
    instances[0].offset.should == 67
    instances[0].length.should == 9

    instances[1].prefix.should == "4, 2007<\/date>\n<body>\nBicycle sales in "
    instances[1].exact.should == "Australia"
    instances[1].suffix.should == " have recorded record sales of 1,273,781 units"
    instances[1].offset.should == 146
    instances[1].length.should == 9

    instances[2].prefix.should == " the traditional company car,\" he said.\n\n\"Some of "
    instances[2].exact.should == "Australia"
    instances[2].suffix.should == "'s biggest corporations now have bicycle fleets,"
    instances[2].offset.should == 952
    instances[2].length.should == 9
  end

  it 'should find the correct instances for each relation' do
    ## This currently tests only for one relation's instances.  A more
    ## thorough test that tests for the instances of each of the many other
    ## relations in the sample doc is desirable in the future.

    rel = @response.relations.select {|e| e.calais_hash.value == "8f3936d9-cf6b-37fc-ae0d-a145959ae3b5" }.first
    rel.instances.size.should == 1

    rel.instances.first.prefix.should == " manufacturers.\n\nThe Cycling Promotion Fund (CPF) "
    rel.instances.first.exact.should == "spokesman Ian Christie said Australians were increasingly using bicycles as an alternative to cars."
    rel.instances.first.suffix.should == " Sales rose nine percent in 2006 while the car"
    rel.instances.first.offset.should == 425
    rel.instances.first.length.should == 99
  end
end
