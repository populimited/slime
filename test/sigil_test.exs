defmodule SigilTest do
  use ExUnit.Case

  import ComponentHelper
  doctest Slime

  defmodule MyApp.PageHTML do
    use Phoenix.Component
    import Slime.Sigil

    def with_sigil(assigns) do
      ~h"""
      p.mx-2 hidden="true"
      """
    end
  end

  test "component renders sigil" do
    html =
      MyApp.PageHTML.with_sigil(%{})
      |> render_to_string()

    assert html == "<p class=\"mx-2\" hidden=\"true\"></p>"
  end
end
