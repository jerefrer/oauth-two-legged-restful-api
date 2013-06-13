require 'spec_helper'

describe '/api/v1/users', :type => :api do

  let(:user) { Factory(:user) }
  let(:api_user) { Factory(:api_user) }
  
  def oauth_consumer(method)
    OAuth::Consumer.new(api_user.api_key, api_user.secret, {
      :site => "http://www.example.com",
      :http_method => method
    })
  end

  def perform(method, url, params = {})
    consumer = oauth_consumer(method)
    request = consumer.create_signed_request(method, url, OAuth::AccessToken.new(consumer), {}, params)
    send method, url, params, 'HTTP_AUTHORIZATION' => request.get_fields('authorization').first
  end

  describe "authorization" do

    it "forbids access without authentication" do
      get '/api/v1/users.json'
      response.status.should == 400
      response.body.should =~ /Invalid request/
    end

    it "forbids access without an existing api_key" do
      consumer = OAuth::Consumer.new('unexisting api key', 'fake secret', {
        :site => "http://example.org",
        :http_method => :get
      })
      url = '/api/v1/users.json'
      request = consumer.create_signed_request(:get, url, OAuth::AccessToken.new(consumer))

      get url, nil, 'HTTP_AUTHORIZATION' => request.get_fields('authorization').first
      response.status.should == 401
      response.body.should =~ /Invalid credentials/
    end

    it "forbids access without the right secret" do
      consumer = OAuth::Consumer.new(api_user.api_key, 'wrong secret', {
        :site => "http://example.org",
        :http_method => :get
      })
      url = '/api/v1/users.json'
      request = consumer.create_signed_request(:get, url, OAuth::AccessToken.new(consumer))

      get url, nil, 'HTTP_AUTHORIZATION' => request.get_fields('authorization').first
      response.status.should == 401
      response.body.should =~ /Invalid credentials/
    end

  end

  describe "listing users" do

    before :each do
      @users = FactoryGirl.create_list(:user, 2)
      perform :get, '/api/v1/users.json'
    end

    it "should be successful" do
      response.status.should == 200
    end

    it "should find the right user" do
      response.body.should == @users.to_json
    end

  end

  describe "showing a user" do

    before :each do
      perform :get, "/api/v1/users/#{user.id}.json"
    end

    it "should be successful" do
      response.status.should == 200
    end

    it "should find the right user" do
      response.body.should == user.to_json
    end

  end

  describe "creating a user" do

    let(:url) { "/api/v1/users" }

    it "successful JSON" do
      expect {
        perform :post, "#{url}.json", :user => FactoryGirl.attributes_for(:user)
        response.status.should == 201
      }.to change{ User.count }.by(1)
    end

    it "unsuccessful JSON" do
      perform :post, "#{url}.json", :user => { }
      response.status.should == 422
    end

  end

  describe "updating a user" do

    let(:url) { "/api/v1/users/#{user.id}" }

    it "successful JSON" do
      perform :put, "#{url}.json", :user => { :username => 'Awesome guy' }
      response.status.should == 204

      user.reload
      user.username.should == "Awesome guy"
    end
    
    it "unsuccessful JSON" do
      initial_username = user.username
      perform :put, "#{url}.json", :user => { :username => '' }
      response.status.should == 422

      user.reload
      user.username.should == initial_username
    end

  end

  describe "deleting a user" do

    let(:url) { "/api/v1/users/#{user.id}" }
    it "works" do
      perform :delete, "#{url}.json"
      response.status.should == 204
    end

  end

end
