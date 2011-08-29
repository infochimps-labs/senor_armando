require 'spec_helper'
require 'senor_armando/formatters/xml'
require 'nokogiri'

require 'ap'

describe SenorArmando::Formatters::XML do
  describe 'with a formatter' do
    before(:each) do
      @xml = SenorArmando::Formatters::XML.new
    end

    it 'checks content type for application/xml' do
      @xml.applies_format?({'Content-Type' => 'application/xml'}).should be_true
    end

    it 'returns false for non-applicaton/xml types' do
      @xml.applies_format?({'Content-Type' => 'application/json'}).should be_false
    end

    it 'formats the body into xml if content-type is xml' do
      body = @xml.format({:a => 1, :b => 2})
      Nokogiri.parse(body).search('a').inner_text.should == '1'
    end

    it 'generates arrays correctly' do
      body = @xml.format([1, 2])
      doc = Nokogiri.parse(body)
      doc.search('item').first.inner_text.should == '1'
      doc.search('item').last.inner_text.should == '2'
    end

    it 'escapes text' do
      evil_string = '<script>do_bad_things</script>'
      body = @xml.format(:evil => evil_string)
      body.should =~ %r{<evil>&lt;script&gt;do_bad_things&lt;(\/|&\#x2F;)script&gt;</evil>}
      doc = Nokogiri.parse(body)
      doc.search('evil').first.inner_text.should == evil_string
    end
  end
end
