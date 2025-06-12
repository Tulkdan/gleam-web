import app/models/item
import pages/home

pub fn home(items: List(item.Item)) {
  home.root(items)
}
