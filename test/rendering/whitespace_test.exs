defmodule RenderWhitespaceTest do
  use ExUnit.Case, async: true

  import Slime, only: [render: 1]

  test "=> inserts a trailing space" do
    slime = """
    | [
    => 1 + 1
    | ]
    """

    assert render(slime) == "[2 ]"
  end

  test "=< inserts a leading space" do
    slime = """
    | [
    =< 1 + 1
    | ]
    """

    assert render(slime) == "[ 2]"
  end

  test "=<> inserts leading and trailing spaces" do
    slime = """
    | [
    =<> 1 + 1
    | ]
    """

    assert render(slime) == "[ 2 ]"
  end
end
