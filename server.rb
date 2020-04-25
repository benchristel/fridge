require "sinatra"
require "json"

$LOAD_PATH.unshift File.join __dir__, "lib"

require "response_for"

ALL_PATHS = "*"

[:get, :put].each do |method|
  send method, ALL_PATHS do
    resp = response_for(
      method: request.request_method,
      path:   request.path,
      params: request.params,
      body:   request.body,
    )

    [resp.status, resp.headers, resp.body]
  end
end
