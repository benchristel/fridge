require "sinatra"
require "json"

revision = 0

get "/revisions/latest" do
  return 200, {"Content-Type" => "application/json"}, JSON(
    id: revision
  )
end

put "*" do
  revision += 1
  return 204, ""
end
