defmodule GiggletonWeb.Demos.BinsTest do
  use GiggletonWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @path "/posts/how-many-bins"

  test "the demo renders in place on the first request, at thirty bins", %{conn: conn} do
    html = conn |> get(@path) |> html_response(200)
    document = LazyHTML.from_document(html)

    assert document |> LazyHTML.query("#post .prose figure#demo-1 .chart svg") |> Enum.count() ==
             1

    assert document |> LazyHTML.query("#demo-1-bins[value='30']") |> Enum.count() == 1
  end

  test "moving the slider redraws the chart", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)
    before = view |> element("#demo-1 .chart") |> render()

    view |> form("#demo-1-form", %{"bins" => "8"}) |> render_change()

    assert has_element?(view, "#demo-1-caption", "in 8 bins")
    refute view |> element("#demo-1 .chart") |> render() == before
  end

  test "a count outside the slider's range is clamped", %{conn: conn} do
    {:ok, view, _html} = live(conn, @path)

    view |> form("#demo-1-form", %{"bins" => "500"}) |> render_change()

    assert has_element?(view, "#demo-1-caption", "in 60 bins")
  end
end
