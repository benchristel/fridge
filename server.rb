require "sinatra"

get "*" do
  puts request.inspect
  return 200, '{"id": 0}'
end
