require 'oauth/request_proxy/rack_request'

module Api
  module V1
    class ApiBaseController < ApplicationController

      before_filter :run_oauth_check

      protected

      def run_oauth_check
        req = OAuth::RequestProxy::RackRequest.new(request)
        return render :json => { :error => "Invalid request" }, :status => 400 unless req.parameters['oauth_consumer_key']

        client = ApiUser.find_by_api_key req.parameters['oauth_consumer_key']
        return render :json => { :error => "Invalid credentials" }, :status => 401 if client.nil?

        begin
          signature = ::OAuth::Signature.build(::Rack::Request.new(env)) { |rp| [nil, client.secret] }
          return render :json => { :error => "Invalid credentials" }, :status => 401 unless signature.verify
        rescue ::OAuth::Signature::UnknownSignatureMethod => e
          return render :json => { :error => "Unknown signature method" }, :status => 400
        end
      end

    end
  end
end