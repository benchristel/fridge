require "sinatra"
require "json"

$LOAD_PATH.unshift File.join __dir__, "lib"

require "response_for"
require "storage_factory"

ALL_PATHS = "*"
STORAGE = StorageFactory.build ENV

[:get, :put].each do |method|
  send method, ALL_PATHS do
    resp = response_for(
      STORAGE,
      request.request_method,
      request.path,
      params: request.params,
      body:   request.body.string,
    )

    [resp.status, resp.headers, resp.body]
  end
end
