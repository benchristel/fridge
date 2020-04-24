require "sinatra"
require "json"

revision = 0

get "*" do
  puts request.inspect
  return 200, {"Content-Type" => "application/json"}, JSON(
    id: revision
  )
end

put "*" do
  revision += 1
  return 204, ""
end
