defmodule RawOutputTest do
  use ExUnit.Case

  import Slime, only: [render: 1]

  test "render raw dynamic content" do
    slime = """
    == "<>"
    """

    assert render(slime) == "<>"
  end

  test "render raw tag content" do
    slime = """
    p == "<>"
    """

    assert render(slime) == ~s[<p><></p>]
  end

  test "render raw text interpolation" do
    slime = ~S"""
    | test #{{"<>"}}
    """

    assert render(slime) == "test <>"
  end
end
