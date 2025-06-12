import envoy
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("SECRET_KEY_BASE")

  let assert Ok(_) =
    wisp_mist.handler(fn(_) { todo }, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
