require "response_for"
require "in_memory_storage"

describe "response_for" do
  let(:storage) { InMemoryStorage.new }

  it "responds 404 to a bogus URL" do
    r = response_for(storage, "GET", "/asdf")
    expect(r).to eq Response.new(404)
  end

  it "gets the latest revision number" do
    r = response_for(storage, "GET", "/revisions/latest")

    expect(r).to eq Response.new(
      200,
      {"Content-Type" => "application/json"},
      JSON("id" => 0)
    )
  end

  it "increments the latest revision number on update" do
    expect {
      response_for(storage, "PUT", "/values/foo")
    }.to change {
      response_for(storage, "GET", "/revisions/latest").body
    }.from(JSON "id" => 0).to(JSON "id" => 1)
  end

  it "responds 204 to an update" do
    expect(response_for(storage, "PUT", "/values/foo"))
      .to eq Response.new(204)
  end
end
