require "net/http"
require "uri"

describe "Fridge" do
  before :all do
    @server_pid = fork do
      exec "make", "run"
    end
    sleep 2
  end

  after :all do
    Process.kill "TERM", @server_pid
    Process.wait @server_pid
  end

  it "responds to a request" do
    expect(Net::HTTP.get(URI("http://localhost:4567")))
      .to eq "Hello, world!"
  end
end
