import gleam/http
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import wisp

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- verbose_log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}

fn verbose_log_request(
  req: wisp.Request,
  handler: fn() -> wisp.Response,
) -> wisp.Response {
  let response = handler()

  let headers = json.to_string(headers_as_json(req))

  [
    http.method_to_string(req.method),
    " ",
    int.to_string(response.status),
    " ",
    req.path,
    " ?",
    option.unwrap(req.query, "-"),
    " :: ",
    headers,
  ]
  |> string.concat
  |> wisp.log_info

  response
}

fn headers_as_json(req: wisp.Request) -> json.Json {
  let jsonify = fn(header: #(String, String)) {
    #(header.0, json.string(header.1))
  }

  req.headers
  |> list.map(jsonify)
  |> json.object
}
