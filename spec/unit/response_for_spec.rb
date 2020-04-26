require "response_for"
require "in_memory_storage"

describe "response_for" do
  let(:storage) { InMemoryStorage.new }

  def r(*args, **kwargs)
    response_for(storage, *args, **kwargs)
  end

  it "responds 404 to a bogus URL" do
    expect(r("GET", "/asdf")).to eq Response.new(404)
  end

  it "gets the latest revision number" do
    expect(r("GET", "/revisions/latest"))
      .to eq Response.new(
        200,
        {"Content-Type" => "application/json"},
        JSON("id" => 0)
      )
  end

  it "increments the latest revision number on update" do
    expect(JSON r("GET", "/revisions/latest").body)
      .to eq "id" => 0

    expect(JSON r("PUT", "/values/foo", body: "version1").body)
      .to eq "revision" => {"id" => 1}

    expect(JSON r("GET", "/revisions/latest").body)
      .to eq "id" => 1

    r("PUT", "/values/foo", body: "version2")

    expect(JSON r("GET", "/revisions/latest").body)
      .to eq "id" => 2
  end

  it "returns a 200 status and JSON from a PUT request" do
    resp = r("PUT", "/values/foo", body: "version2")
    expect(resp.status).to eq 200
    expect(resp.headers).to eq "Content-Type" => "application/json"
  end

  it "GETs an empty string when asked for a nonexistent value" do
    expect(r("GET", "/values/foo"))
      .to eq Response.new(
        200,
        {"Content-Type" => "text/plain"},
        ""
      )
  end

  it "GETs a value that was previously set" do
    r("PUT", "/values/foo", body: "hello")

    expect(r("GET", "/values/foo"))
      .to eq Response.new(
        200,
        {"Content-Type" => "text/plain"},
        "hello"
      )
  end

  it "stores multiple values under different keys" do
    r("PUT", "/values/ones", body: "111")
    r("PUT", "/values/twos", body: "222")

    expect(r("GET", "/values/ones").body).to eq "111"
    expect(r("GET", "/values/twos").body).to eq "222"
  end

  it "gets a previous revision of a value" do
    r("PUT", "/values/ones", body: "11")
    r("PUT", "/values/ones", body: "11111")

    expect(r("GET", "/values/ones", params: {"revision" => "1"}).body)
      .to eq "11"
  end

  it "gets a value at an 'in between' revision" do
    r("PUT", "/values/ones", body: "11")
    r("PUT", "/values/twos", body: "222")
    r("PUT", "/values/ones", body: "11111")

    expect(r("GET", "/values/ones", params: {"revision" => "2"}).body)
      .to eq "11"
  end

  it "rejects requests with a non-numeric revision" do
    expect(r("GET", "/values/a", params: {"revision" => "a"}).status)
      .to eq 400
  end

  it "responds 404 to requests for a nonexistent revision" do
    expect(r("GET", "/values/a", params: {"revision" => "999"}).status)
      .to eq 404
  end
end
