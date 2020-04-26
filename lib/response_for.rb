require "json"

Response = Struct.new(:status, :headers, :body)

class Revision
  def self.parse(raw_revision, latest_revision)
    case raw_revision
    in nil
      Valid.new latest_revision
    in /^[0-9]+$/
      if raw_revision.to_i > latest_revision
        Nonexistent.new
      else
        Valid.new raw_revision.to_i
      end
    else
      Malformed.new
    end
  end

  Valid = Struct.new(:to_i)
  Nonexistent = Class.new
  Malformed = Class.new
end

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
