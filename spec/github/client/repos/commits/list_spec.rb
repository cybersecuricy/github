# encoding: utf-8

require 'spec_helper'

describe Github::Client::Repos::Commits, '#list' do
  let(:user) { 'peter-murach' }
  let(:repo) { 'github' }
  let(:request_path) { "/repos/#{user}/#{repo}/commits" }

  before {
    stub_get(request_path).to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for(subject) }

  context "resource found" do
    let(:body)   { fixture('repos/commits.json') }
    let(:status) { 200 }

    it { is_expected.to respond_to :all }

    it { expect { subject.list }.to raise_error(ArgumentError) }

    it { expect { subject user }.to raise_error(ArgumentError) }

    it "should get the resources" do
      subject.list user, repo
      expect(a_get(request_path)).to have_been_made
    end

    it_should_behave_like 'an array of resources' do
      let(:requestable) { subject.list user, repo }
    end

    it "should get commit information" do
      commits = subject.list user, repo
      expect(commits.first.author.name).to eq 'Scott Chacon'
    end

    it "should yield to a block" do
      yielded = []
      result = subject.list(user, repo) { |obj| yielded << obj }
      expect(yielded).to eq result
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.list user, repo }
  end
end # list
