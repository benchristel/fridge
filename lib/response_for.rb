require "json"

$revision = 0

Response = Struct.new(:status, :headers, :body)

def response_for(method:, path:, params: {}, body: "")
  if path == "/revisions/latest"
    Response.new 200,
      {"Content-Type" => "application/json"},
      JSON(id: $revision)
  elsif method == "PUT"
    $revision += 1
    Response.new 204
  else
    Response.new 404
  end
end
