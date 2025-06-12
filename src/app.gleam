import app/router
import app/web
import envoy
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("SECRET_KEY_BASE")

  let ctx = web.Context(static_directory: static_directory(), items: [])

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  priv_directory <> "/static"
}
