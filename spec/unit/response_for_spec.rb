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

    r("PUT", "/values/foo")

    expect(JSON r("GET", "/revisions/latest").body)
      .to eq "id" => 1
  end

  it "responds 204 to an update" do
    expect(r("PUT", "/values/foo"))
      .to eq Response.new(204)
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
end
