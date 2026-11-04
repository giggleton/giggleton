defmodule Giggleton.ResidentsTest do
  use ExUnit.Case, async: true

  alias Giggleton.{Blog, Residents}
  alias Giggleton.Blog.NotFoundError
  alias Giggleton.Residents.Resident

  test "the residents are in village order" do
    assert Residents.ids() == [:giggly, :pica, :scales]
    assert Enum.map(Residents.all_residents(), & &1.id) == Residents.ids()
  end

  test "every resident has a stitch pattern" do
    for id <- Residents.ids() do
      assert Atom.to_string(id) in GiggletonWeb.PixelArt.names()
    end
  end

  test "a resident is found by atom or by the string in their address" do
    scales = Residents.get_resident!(:scales)

    assert scales.name == "Scales"
    assert Residents.get_resident!("scales") == scales
    assert_raise NotFoundError, fn -> Residents.get_resident!("ggity") end
    assert_raise NotFoundError, fn -> Residents.get_resident!(:ggity) end
  end

  test "neighbours wrap round the ends of the street" do
    [giggly, pica, scales] = Residents.all_residents()

    assert Residents.neighbours(giggly) == {scales, pica}
    assert Residents.neighbours(pica) == {giggly, scales}
  end

  test "a resident's charts are inlined, as in a post" do
    giggly = Residents.get_resident!(:giggly)

    assert giggly.body =~ ~s(<figure class="stitched chart-frame")
    assert giggly.charts == ["priv/static/charts/giggly/garden.svg"]

    assert Residents.get_resident!(:pica).charts == [
             "priv/static/charts/pica/named.svg",
             "priv/static/charts/pica/registered.svg"
           ]
  end

  test "posts about a resident are those that name them" do
    for id <- Residents.ids() do
      assert Enum.all?(Blog.posts_about(id), &(id in &1.residents))
    end

    assert Blog.posts_about(:ggity) == []
  end

  describe "building a resident" do
    @attrs %{
      name: "Tack",
      species: "jackdaw",
      vocation: "Keeps the noticeboard.",
      home: "The noticeboard",
      thread: :gold,
      says: "Pinned it.",
      install: ~s({:tack, "~> 0.1"}),
      source: "https://github.com/giggleton/tack",
      order: 4
    }

    test "takes the id from the file name, with no documentation link by default" do
      tack = Resident.build("priv/content/residents/tack.md", @attrs, "<p>Hi</p>")

      assert tack.id == :tack
      assert tack.docs == nil
      assert tack.body == "<p>Hi</p>"
    end

    test "rejects a thread that isn't one of the sampler's" do
      assert_raise ArgumentError, ~r/thread/, fn ->
        Resident.build("tack.md", %{@attrs | thread: :purple}, "")
      end
    end

    test "rejects a misspelt key and a missing one" do
      assert_raise KeyError, fn ->
        Resident.build("tack.md", Map.put(@attrs, :vocaton, "x"), "")
      end

      assert_raise ArgumentError, fn ->
        Resident.build("tack.md", Map.delete(@attrs, :says), "")
      end
    end
  end
end
