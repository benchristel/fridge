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

  let :server_port do
    4567
  end

  let :http_client do
    Net::HTTP.new("localhost", server_port)
  end

  def get(path)
    Net::HTTP::Get.new path
  end

  def put(path)
    Net::HTTP::Put.new path
  end

  it "responds 404 to a request for a bogus URL" do
    response = http_client.request get "/blep"
    expect(response.code).to eq "404"
  end

  it "responds to a request for the latest revision" do
    response = http_client.request get "/revisions/latest"

    expect(JSON(response.body)).to eq "id" => 0
    expect(response["Content-Type"]).to eq "application/json"
  end

  it "increments the latest revision number when you set a key" do
    http_client.request put "/values/my-test-key"

    response = http_client.request get "/revisions/latest"

    expect(JSON(response.body)).to eq "id" => 1
  end
end
