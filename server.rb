require "sinatra"

get "*" do
  puts request.inspect
  return 200, {"Content-Type" => "application/json"}, '{"id": 0}'
end
