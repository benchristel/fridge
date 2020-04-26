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
    if params["revision"] && params["revision"] !~ /^[0-9]+$/
      return Response.new(400)
    end
    revision = params["revision"] || storage.revision
    if revision.to_i > storage.revision
      return Response.new(404)
    end
    Response.new(
      200,
      {"Content-Type" => "text/plain"},
      storage.get(key, revision)
    )

  in "PUT", ["values", key]
    storage.update(key, body)
    Response.new(
      200,
      {"Content-Type" => "application/json"},
      JSON(revision: {id: storage.revision})
    )

  else
    Response.new(404)

  end
end
