require "json"

Response = Struct.new(:status, :headers, :body)

def response_for(storage, method, path, params: {}, body: "")
  case [method, path]

  in "GET", "/revisions/latest"
    Response.new(
      200,
      {"Content-Type" => "application/json"},
      JSON(id: storage.revision)
    )

  in "GET", %r{^/values/(.+)}
    key = %r{^/values/(.+)}.match(path)[1]
    Response.new(
      200,
      {"Content-Type" => "text/plain"},
      storage.get(key)
    )

  in "PUT", %r{^/values/(.+)}
    key = %r{^/values/(.+)}.match(path)[1]
    storage.update(key, body)
    Response.new(204)

  else
    Response.new(404)

  end
end
