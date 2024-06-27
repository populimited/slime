defmodule TagTest do
  use ExUnit.Case, async: true

  import Slime, only: [render: 1, render: 2]

  test "dashed-strings can be used as tags" do
    assert render(~s(my-component text)) == ~s(<my-component>text</my-component>)
  end

  test "render nested tags" do
    slime = """
    #id.class
      p Hello World
    """

    assert render(slime) == ~s(<div class="class" id="id"><p>Hello World</p></div>)
  end

  test "render nested tags with text node" do
    slime = """
    #id.class
      p
        | Hello World
    """

    assert render(slime) == ~s(<div class="class" id="id"><p>Hello World</p></div>)
  end

  test "render attributes and inline children" do
    assert render(~s(div id="id" text content)) == ~s(<div id="id">text content</div>)
    assert render(~s(div id="id" = @elixir_func), %{elixir_func: "text"}) == ~s(<div id="id">text</div>)
  end
end
