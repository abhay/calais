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
end