require "json"

Response = Struct.new(:status, :headers, :body)

def response_for(storage, method, path, params: {}, body: "")
  if path == "/revisions/latest"
    Response.new 200,
      {"Content-Type" => "application/json"},
      JSON(id: storage.revision)
  elsif method == "PUT"
    storage.update
    Response.new 204
  else
    Response.new 404
  end
end
