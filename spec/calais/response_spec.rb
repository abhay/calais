require File.join(File.dirname(__FILE__), %w[.. helper])

describe Calais::Response, :new do
  it 'accepts an rdf string to generate the response object' do
    lambda { Calais::Response.new(SAMPLE_RESPONSE) }.should_not raise_error
  end
end

describe Calais::Response, :new do
  before :all do
    @response = Calais::Response.new(SAMPLE_RESPONSE)
  end

  it 'should extract document information' do
    @response.language.should == 'English'
    @response.submission_date.should be_a_kind_of(DateTime)
    @response.signature.should == 'digestalg-1|iCEVI2NK1nAAvP+p5uaqnHISxdo=|U3QC5z6ZN1DLUJrqiP6gpTuxrdAxOaVOrjUQVuarCmb+zoqbm2fypA=='
    @response.submitter_code.should == '4a388fbc-9897-def9-9233-efddbfbca363'
    @response.request_id.should == '896ffd83-ad5f-4e4b-892b-4cc337a246af'
    @response.doc_title.should == 'Record number of bicycles sold in Australia in 2006'
    @response.doc_date.should be_a_kind_of(Date)
  end

  it 'should extract entities' do
    entities = @response.entities
    entities.map { |e| e.type }.sort.uniq.should == %w[City Continent Country IndustryTerm Organization Person ProvinceOrState]
  end

  it 'should extract relations' do
    relations = @response.relations
    relations.map { |e| e.type }.sort.uniq.should == %w[GenericRelations PersonAttributes PersonProfessional Quotation]
  end

  it 'should extract geographies' do
    geographies = @response.geographies
    geographies.map { |e| e.name }.sort.uniq.should == %w[Australia Hobart,Tasmania,Australia Tasmania,Australia]
  end

  it 'should extract relevances' do
    @response.instance_variable_get("@relevances").size.should == 10
  end

  it 'should assign a floating-point relevance to each entity' do
    @response.entities.each {|e| e.relevance.class.should == Float }
  end

  it 'should assign the correct relevance to each entity' do
    correct_relevances = {
      "84a34c48-25ac-327f-a805-7b81fd570f7d" => 0.725,
      "9853f11e-5efa-3efc-90b9-0d0450f7d673" => 0.396,
      "9fa3fb8a-f517-32c7-8a46-3c1506ea3a70" => 0.156,
      "ed0e83f9-87e8-3da6-ab46-cd6be116357c" => 0.291,
      "e05f3d33-1622-3172-836c-b48637a156d3" => 0.316,
      "d0ca04b6-9cf5-3595-ad4b-7758a0b57997" => 0.156,
      "0bb9cdb4-3cb7-342a-9901-6d1f12b32f6a" => 0.31,
      "3979e581-0823-3e84-9257-1ca36db4665e" => 0.228,
      "0c3d5340-106f-390e-92d3-a4aa18004fb8" => 0.158,
      "3bcf2655-ff2a-3a80-8de4-558b9626ad21" => 0.644
    }
    @response.entities.each {|e| correct_relevances[e.hash.value].should == e.relevance }
  end

  it 'should find the correct document categories returned by OpenCalais' do
    @response.categories.map {|c| c.name }.sort.should == %w[Business_Finance Technology_Internet]
  end

  it 'should find the correct document category scores returned by OpenCalais' do
    @response.categories.map {|c| c.score }.should == [1.0, 1.0]
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

    rel = @response.relations.select {|e| e.hash.value == "8f3936d9-cf6b-37fc-ae0d-a145959ae3b5" }.first
    rel.instances.size.should == 1

    rel.instances.first.prefix.should == " manufacturers.\n\nThe Cycling Promotion Fund (CPF) "
    rel.instances.first.exact.should == "spokesman Ian Christie said Australians were increasingly using bicycles as an alternative to cars."
    rel.instances.first.suffix.should == " Sales rose nine percent in 2006 while the car"
    rel.instances.first.offset.should == 425
    rel.instances.first.length.should == 99
  end
end