require File.join(File.dirname(__FILE__), %w[.. helper])

describe Calais::Response, :new do
  it 'accepts a json string to generate the response object' do
    lambda { Calais::Response.new(SAMPLE_RESPONSE) }.should_not raise_error
  end
end


describe Calais::Response, :new do
  before :all do
    @response = Calais::Response.new(SAMPLE_RESPONSE)
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

end
