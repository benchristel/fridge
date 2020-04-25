require "response_for"
require "in_memory_storage"

describe "response_for" do
  let(:storage) { InMemoryStorage.new }

  def r(*args)
    response_for(storage, *args)
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
end
