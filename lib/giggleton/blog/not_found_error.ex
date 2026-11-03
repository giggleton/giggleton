defmodule Giggleton.Blog.NotFoundError do
  @moduledoc "Raised for a post or tag that doesn't exist. Plug turns it into a 404."
  defexception [:message, plug_status: 404]
end
