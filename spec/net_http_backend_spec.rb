require 'rubygems'
require 'spec'
require File.expand_path('../lib/http_client/net_http_backend', File.dirname(__FILE__))

module Net
  class HTTP
  end
end

describe HttpClient::NetHttpBackend do
  before :each do
    @listener     = stub("listener",
                         :null_object => true)
    @net_http_cxn = stub("net/http connection",
                         :null_object => true)
    Net::HTTP.stub!(:start).and_return(@net_http_cxn)
  end

  describe "when opening a connection to example.com" do
    after :each do
      open_connection
    end

    def open_connection
      @cxn = HttpClient::NetHttpBackend.open("example.com")
    end

    it "should open a Net::HTTP connection" do
      Net::HTTP.should_receive(:start).and_return(@net_http_cxn)
    end

    it "should pass in the host to Net::HTTP" do
      Net::HTTP.should_receive(:start).with("example.com", anything)
    end

    it "should default the port to 80" do
      Net::HTTP.should_receive(:start).with(anything, 80)
    end

    describe "and given a listener" do
      def open_connection
        @cxn      = HttpClient::NetHttpBackend.open("example.com", :listener => @listener)
      end

      it "should call listener.handle_initiate before opening connection" do
        @listener.should_receive(:handle_initiate).ordered
        Net::HTTP.should_receive(:start).ordered
      end

      it "should call listener.handle_open once the connection is started" do
        Net::HTTP.should_receive(:start).ordered
        @listener.should_receive(:handle_open).ordered
      end
    end
  end

  describe "when opened" do
    before :each do
      @cxn = HttpClient::NetHttpBackend.open("example.com")
    end

    describe "and then closed" do
      after :each do
        @cxn.close!
      end

      it "should call #finish on the underlying connection" do
        @net_http_cxn.should_receive(:finish)
      end
    end
  end

  describe "when opened with a listener" do
    before :each do
      @cxn = HttpClient::NetHttpBackend.open("example.com", :listener => @listener)
    end

    describe "then closed" do
      after :each do
        @cxn.close!
      end

      it "should call listener.handle_close after closing the underlying connection" do
        @net_http_cxn.should_receive(:finish).ordered
        @listener.should_receive(:handle_close).ordered
      end
    end
  end
end
