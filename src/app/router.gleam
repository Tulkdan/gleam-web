import app/web.{type Context}
import lustre/element
import pages/layout
import pages/pages
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> {
      [pages.home()]
      |> layout.layout
      |> element.to_document_string_tree
      |> wisp.html_response(200)
    }

    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessed-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
