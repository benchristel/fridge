require "json"
require "revision"

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
    case Revision.parse params["revision"], storage.revision
    in Revision::Malformed
      Response.new(400)
    in Revision::Nonexistent
      Response.new(404)
    in Revision::Valid => revision
      Response.new(
        200,
        {"Content-Type" => "text/plain"},
        storage.get(key, revision)
      )
    end

  in "PUT", ["values", key]
    revision = storage.update(key, body)
    Response.new(
      200,
      {"Content-Type" => "application/json"},
      JSON(revision: {id: revision})
    )

  else
    Response.new(404)

  end
end
