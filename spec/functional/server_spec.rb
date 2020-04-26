require "net/http"
require "uri"
require "json"

STORAGE_DIR = "/tmp/fridge-tests"

describe "Fridge" do
  before :each do
    FileUtils.rm_rf(STORAGE_DIR)

    # environment variables for the server child process
    ENV["FRIDGE_STORAGE_DIR"]  = STORAGE_DIR
    ENV["FRIDGE_STORAGE_TYPE"] = "file"

    @server_pid = fork do
      exec "make", "run"
    end
    sleep 2
  end

  after :each do
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

  def put(path, body: "")
    Net::HTTP::Put.new(path).tap { |r| r.body = body }
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

  it "parses query parameters" do
    http_client.request put "/values/my-test-key", body: "foo"
    http_client.request put "/values/my-test-key", body: "bar"

    response =
      http_client.request get "/values/my-test-key?revision=1"

    expect(response.body).to eq "foo"
  end
end
