require "net/http"
require "uri"
require "json"

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

  it "responds to a request for the latest revision" do
    expect(JSON(Net::HTTP.get(URI("http://localhost:4567/revisions/latest"))))
      .to eq({
          "id" => 0
        })
  end
end
