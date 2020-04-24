require "sinatra"

get "*" do
  puts request.inspect
  return 200, "Hello, world!"
end
