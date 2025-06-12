import app/models/item
import app/web
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import wisp

type ItemsJson {
  ItemsJson(id: String, title: String, completed: Bool)
}

pub fn items_middleware(
  req: wisp.Request,
  ctx: web.Context,
  handle_request: fn(web.Context) -> wisp.Response,
) {
  let parsed_items = case wisp.get_cookie(req, "items", wisp.PlainText) {
    Ok(json_string) -> {
      let decoder = {
        use id <- decode.field("id", decode.string)
        use title <- decode.field("title", decode.string)
        use completed <- decode.field("completed", decode.bool)
        decode.success(ItemsJson(id: id, title: title, completed: completed))
      }

      let result = json.parse(json_string, decode.list(of: decoder))
      case result {
        Ok(items) -> items
        Error(_) -> []
      }
    }
    Error(_) -> []
  }

  let items = create_items_from_json(parsed_items)

  let ctx = web.Context(..ctx, items: items)

  handle_request(ctx)
}

fn create_items_from_json(items: List(ItemsJson)) -> List(item.Item) {
  items
  |> list.map(fn(item) {
    let ItemsJson(id, title, completed) = item
    item.create_item(option.Some(id), title, completed)
  })
}

pub fn post_create_item(req: wisp.Request, ctx: web.Context) {
  use form <- wisp.require_form(req)

  let current_items = ctx.items

  let result = {
    use item_title <- result.try(list.key_find(form.values, "todo_title"))
    let new_item = item.create_item(option.None, item_title, False)
    list.append(current_items, [new_item])
    |> todos_to_json
    |> Ok
  }

  case result {
    Ok(todos) -> {
      wisp.redirect("/")
      |> wisp.set_cookie(req, "items", todos, wisp.PlainText, 60 * 60 * 24)
    }
    Error(_) -> wisp.bad_request()
  }
}

fn todos_to_json(items: List(item.Item)) -> String {
  "["
  <> items
  |> list.map(item_to_json)
  |> string.join(",")
  <> "]"
}

fn item_to_json(item: item.Item) -> String {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("completed", json.bool(item.item_status_to_bool(item.status))),
  ])
  |> json.to_string
}
