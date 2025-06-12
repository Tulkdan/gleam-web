import app/routes/item_routes
import app/web.{type Context}
import gleam/http
import lustre/element
import pages/layout
import pages/pages
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)
  use ctx <- item_routes.items_middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> {
      [pages.home(ctx.items)]
      |> layout.layout
      |> element.to_document_string_tree
      |> wisp.html_response(200)
    }

    ["items", "create"] -> {
      use <- wisp.require_method(req, http.Post)
      item_routes.post_create_item(req, ctx)
    }

    ["items", id] -> {
      use <- wisp.require_method(req, http.Delete)
      item_routes.delete_item(req, ctx, id)
    }

    ["items", id, "completion"] -> {
      use <- wisp.require_method(req, http.Patch)
      item_routes.patch_toggle_todo(req, ctx, id)
    }

    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessed-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
