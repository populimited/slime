defmodule RenderKeepLinesTest do
  use ExUnit.Case

  import Slime, only: [render: 1]

  setup do
    keep_lines_was = Application.get_env(:slime, :keep_lines)
    Application.put_env(:slime, :keep_lines, true)

    on_exit(fn ->
      Application.put_env(:slime, :keep_lines, keep_lines_was)
    end)
  end

  test "Keep simple tags lines" do
    slime = """
    h1 test
    h2 multiple
    h3 lines
    """

    assert render(slime) == "<h1>test</h1>\n<h2>multiple</h2>\n<h3>lines</h3>"
  end

  test "Keep tags with childs lines" do
    slime = """
    h1
      | test
      | multiple
      | lines
    """

    assert render(slime) == "<h1>\ntest\nmultiple\nlines</h1>"
  end

  test "Keep lines when empty lines present" do
    slime = """
    h1


      | multiple

      | lines
    """

    assert render(slime) == "<h1>\n\n\nmultiple\n\nlines</h1>"
  end

  test "Keep lines for inline tags" do
    slime = """
    h1: span test
    """

    assert render(slime) == "<h1><span>test</span></h1>"
  end

  test "Keep lines for inline tags with children" do
    slime = """
    h1: span
      span test 1
    """

    assert render(slime) == "<h1><span>\n<span>test 1</span></span></h1>"
  end

  test "Keep lines for embedded engine (javascript)" do
    slime = """
    javascript:
      console.log("test");
    """

    assert render(slime) == "<script>\nconsole.log(\"test\");</script>"
  end

  test "Keep lines for embedded engine (elixir)" do
    slime = """
    elixir:
      a = "test"
      b = "test"
    = a <> b
    """

    assert render(slime) == "\n\n\ntesttest"
  end

  test "Keep lines for embedded engine (eex)" do
    slime = """
    eex:
      Test <%= "test" %>
      Test <%= "test" %>
    """

    assert render(slime) == "\nTest test\nTest test"
  end
end
