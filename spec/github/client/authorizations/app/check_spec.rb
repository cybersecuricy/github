# encoding: utf-8

require 'spec_helper'

RSpec.describe Github::Client::Authorizations::App, '#check' do
  let(:basic_auth) { 'login:password' }
  let(:host)       { "https://api.github.com" }
  let(:request_path) { "/applications/#{client_id}/tokens/#{access_token}" }
  let(:client_id) { 1 }
  let(:access_token) { 'abc123' }

  subject { described_class.new(basic_auth: basic_auth) }

  before do
    stub_get(request_path, host).to_return(body: body, status: status,
      headers: {content_type: 'application/json; charset=utf-8'})
  end

  context 'when app makes a request' do
    let(:body)   { "" }
    let(:status) { 200 }

    it "checks resource successfully" do
      subject.check client_id, access_token
      expect(a_get(request_path, host)).to have_been_made
    end

    it "fails without client_id" do
      expect { subject.check }.to raise_error(ArgumentError)
    end

    it "fails without access_token" do
      expect {subject.check(client_id)}.to raise_error(ArgumentError)
    end
  end

  context 'when app checks a token that is valid' do
    let(:body)   { fixture('auths/check.json') }
    let(:status) { 200 }


    it "returns the resource" do
      authorization = subject.check client_id, access_token
      expect(authorization).to be_a Github::ResponseWrapper
    end

    it "gets the authorization information" do
      authorization = subject.check client_id, access_token
      expect(authorization.token).to eq 'abc123'
    end
  end

  context 'when app checks a token that is not valid' do
    let(:body)      { '' }
    let(:status)    { 404 }

    it "does not raise error for expected 404" do
      expect { subject.check client_id, access_token }.to_not raise_error
    end

    it "returns nil" do
      authorization = subject.check client_id, access_token
      expect(authorization).to be_nil
    end
  end
end # check
