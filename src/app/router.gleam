import app/web
import gleam/bit_array.{base64_encode, base64_url_decode, to_string}
import gleam/dynamic.{dynamic}
import gleam/http.{Get}
import gleam/int
import gleam/json
import gleam/list.{map}
import gleam/result
import gleam/string_builder
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  // route requests by pattern-matching path segments
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req)
    ["eicar"] -> eicar(req)
    ["json"] -> json_from_params(req)
    ["json", "b64", enc] -> json_from_b64(req, enc)
    ["get", ..] -> only_get(req)
    ["log", ..] -> log_body(req)
    ["404"] -> wisp.not_found()
    ["418"] ->
      wisp.response(418)
      |> wisp.string_body("I'm a little teapot, short and stout!")
    ["500"] -> wisp.internal_server_error()
    _ -> wisp.not_found()
  }
}

fn home_page(_req: Request) -> Response {
  let html = string_builder.from_string("Hello, world!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn eicar(_req: Request) -> Response {
  wisp.log_info("EICAR file requested")
  wisp.ok()
  |> wisp.string_body(
    "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*",
  )
}

fn json_from_params(req: Request) -> Response {
  let data = {
    wisp.get_query(req)
    |> map(fn(pair: #(String, String)) { #(pair.0, json.string(pair.1)) })
    |> json.object
  }

  wisp.log_info("generated json: " <> json.to_string(data))

  wisp.json_response(json.to_string_builder(data), 200)
}

fn json_from_b64(_req: Request, enc: String) -> Response {
  let data = {
    base64_url_decode(enc)
    |> result.map(to_string)
    |> result.flatten
  }

  let parsed = {
    data
    |> result.map(json.decode(_, dynamic))
  }

  let decoded = {
    result.unwrap(data, or: "")
    |> string_builder.from_string
  }

  case parsed {
    Ok(_) -> {
      wisp.ok()
      |> wisp.json_body(decoded)
    }
    Error(_) -> wisp.bad_request()
  }
}

fn only_get(req: Request) -> Response {
  // return a 405 Method Not Allowed response for non-GET requests
  use <- wisp.require_method(req, Get)

  let html = string_builder.from_string("Hello, world!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn log_body(req: Request) -> Response {
  use body <- wisp.require_bit_array_body(req)

  let size = bit_array.byte_size(body)

  wisp.log_info(
    req.path
    <> " "
    <> int.to_string(size)
    <> "bytes - "
    <> base64_encode(body, True),
  )

  wisp.ok()
}
