require "json"

Response = Struct.new(:status, :headers, :body)

class RestResource
  def self.build(path)
    match = %r{^/values/(.+)}.match(path)
    if match
      return ValueRestResource.new(match[1])
    end

    match = %r{/revisions/latest}.match(path)
    if match
      return LatestRevisionRestResource.new
    end
  end
end

ValueRestResource = Struct.new(:key)
LatestRevisionRestResource = Class.new

def response_for(storage, method, path, params: {}, body: "")
  resource = RestResource.build(path)

  case [method, resource]

  in "GET", LatestRevisionRestResource
    Response.new(
      200,
      {"Content-Type" => "application/json"},
      JSON(id: storage.revision)
    )

  in "GET", ValueRestResource => res
    Response.new(
      200,
      {"Content-Type" => "text/plain"},
      storage.get(res.key)
    )

  in "PUT", ValueRestResource => res
    storage.update(res.key, body)
    Response.new(204)

  else
    Response.new(404)

  end
end
