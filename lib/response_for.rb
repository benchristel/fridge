require "json"

Response = Struct.new(:status, :headers, :body)

def response_for(storage, method, path, params: {}, body: "")
  parsed_path = path.split("/").drop(1)

  case [method, parsed_path]

  in "GET", ["revisions", "latest"]
    Response.new(
      200,
      {"Content-Type" => "application/json"},
      JSON(id: storage.revision)
    )

  in "GET", ["values", key]
    Response.new(
      200,
      {"Content-Type" => "text/plain"},
      storage.get(key)
    )

  in "PUT", ["values", key]
    storage.update(key, body)
    Response.new(204)

  else
    Response.new(404)

  end
end
