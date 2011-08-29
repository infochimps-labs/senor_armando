require 'spec_helper'
require 'senor_armando/rack/set_content_type'

describe SenorArmando::Rack::SetContentType do
  let(:env) do
    env = Goliath::Env.new
    env['params'] = {}
    env
  end

  let(:media_types){ nil }

  let(:app){ mock('app').as_null_object }
  let(:render){ SenorArmando::Rack::SetContentType.new(app, media_types) }

  it 'accepts an app' do
    lambda { SenorArmando::Rack::SetContentType.new('my app') }.should_not raise_error
  end

  it 'returns the status, body and app headers' do
    app_body = {'c' => 'd'}

    app.should_receive(:call).and_return([200, {'a' => 'b'}, app_body])
    status, headers, body = render.call(env)

    status.should == 200
    headers['a'].should == 'b'
    body.should == app_body
  end

  describe 'Vary' do
    it 'adds Accept to provided Vary header' do
      app.should_receive(:call).and_return([200, {'Vary' => 'Cookie'}, {}])
      status, headers, body = render.call(env)
      headers['Vary'].should == 'Cookie,Accept'
    end

    it 'sets Accept if there is no Vary header' do
      app.should_receive(:call).and_return([200, {}, {}])
      status, headers, body = render.call(env)
      headers['Vary'].should == 'Accept'
    end
  end

  describe 'Format from path' do
    describe 'successfully' do
      before(:each) do
        app.should_receive(:call).and_return([200, {}, {}])
      end
      let(:media_types){ ['json', 'xml', 'html' ] }

      it 'extracts format into params' do
        env['PATH_INFO'] = '/foo/bar.json'
        status, headers, body = render.call(env)
        env.params['format'].should == 'json'
      end

      it 'strips extension' do
        env['PATH_INFO'] = '/foo/bar.json'
        status, headers, body = render.call(env)
        env['PATH_INFO'].should == '/foo/bar'
      end

      it 'does not get confused with dots in path' do
        env['PATH_INFO']            =  '/path.to/resource.xml'
        status, headers, body       =  render.call(env)
        env['PATH_INFO'].should     == '/path.to/resource'
        env.params['format'].should == 'xml'
        env['HTTP_ACCEPT'].should   == 'application/xml'
      end

      it 'prepends requested media type to Accept header' do
        env['PATH_INFO']           = '/path/resource.html'
        env['HTTP_ACCEPT']         = 'application/xml'
        status, headers, body = render.call(env)
        env['HTTP_ACCEPT'].should == 'text/html,application/xml'
      end

      it 'does nothing for url without extension' do
        env['PATH_INFO']           = '/path/resource'
        env['HTTP_ACCEPT']         = 'application/xml'
        status, headers, body = render.call(env)
        env['HTTP_ACCEPT'].should == 'application/xml'
      end
    end

    it 'sets "json" as the only accepted type if none is given' do
      mw = SenorArmando::Rack::SetContentType.new(app)
      ::Rack::RespondTo.media_types.should == ['json']
      mw.send(:media_types).should equal(::Rack::RespondTo.media_types)
    end

    describe 'unsuccessfully' do
      it 'does not accept a lonely dot' do
        env['PATH_INFO']            =  '/path.to/resource.'
        lambda{ status, headers, body = render.call(env) }.should raise_error(Goliath::Validation::BogusFormatError, /Allowed formats .json. do not include \./)
      end

      it 'does not strip extensions not specified at creation' do
        env['PATH_INFO']           = '/path/resource.my_pants'
        lambda{ status, headers, body = render.call(env) }.should raise_error(Goliath::Validation::BogusFormatError, /Allowed formats .json. do not include \.my_pants/)
      end
    end
  end

  CONTENT_TYPES = {
    'rss' => 'application/rss+xml',
    'xml' => 'application/xml',
    'html' => 'text/html',
    'json' => 'application/json',
    'yaml' => 'text/yaml',
  }

  describe 'Content-Type' do
    before(:each) do
      app.should_receive(:call).and_return([200, {}, {}])
    end
    let(:media_types){ CONTENT_TYPES.keys }

    describe 'from header' do
      CONTENT_TYPES.values.each do |type|
        it "handles content type for #{type}" do
          env['HTTP_ACCEPT'] = type
          status, headers, body = render.call(env)
          headers['Content-Type'].should =~ /^#{Regexp.escape(type)}/
        end
      end
    end

    describe 'from URL param' do
      CONTENT_TYPES.each_pair do |format, content_type|
        it "converts #{format} to #{content_type}" do
          env['params']['format'] = format
          status, headers, body = render.call(env)
          headers['Content-Type'].should =~ /^#{Regexp.escape(content_type)}/
        end
      end
    end

    it 'prefers URL format over header' do
      env['HTTP_ACCEPT'] = 'application/xml'
      env['params']['format'] = 'json'
      status, headers, body = render.call(env)
      headers['Content-Type'].should =~ %r{^application/json}
    end

    it 'prefers file extension over URL format over header' do
      env['HTTP_ACCEPT'] = 'application/xml'
      env['params']['format'] = 'json'
      env['PATH_INFO']   = '/hi/there.yaml'
      status, headers, body = render.call(env)
      headers['Content-Type'].should =~ %r{^text/yaml}
    end

    describe 'charset' do
      it 'is set if not present' do
        env['params']['format'] = 'json'
        status, headers, body = render.call(env)
        headers['Content-Type'].should =~ /; charset=utf-8$/
      end
    end
  end
end
