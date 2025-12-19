defmodule FunctionComponentTest do
  use ExUnit.Case, async: true

  import Slime.Renderer, only: [precompile: 1]

  test "function components work with scalar attributes" do
    slime = ":my_function foo=1"
    heex = ~s(<.my_function foo="1"/>)
    assert precompile(slime) == heex
  end

  test "function components work with assigns" do
    slime = ":my_function foo=one"
    heex = ~s(<.my_function foo={one}/>)
    assert precompile(slime) == heex
  end

  test "function components work with inner html" do
    slime = ~s"""
    :my_function
      div
        | Inner Html
    """

    heex = ~s(<.my_function><div>Inner Html</div></.my_function>)

    assert precompile(slime) == heex
  end

  test "function components work with inner html and assigns" do
    slime = ~s"""
    :my_function foo=bar
      div
        | Inner Html
    """

    heex = ~s(<.my_function foo={bar}><div>Inner Html</div></.my_function>)

    assert precompile(slime) == heex
  end

  test "assigns work in interpolated string expressions" do
    slime = ~s(div id="user_\#{id}")
    heex = ~s(<div id={"user_\#{id}"}></div>)
    assert precompile(slime) == heex
  end

  test "function components work when called with full module name" do
    slime = ":MyApp.module.city"
    heex = "<MyApp.module.city/>"
    assert precompile(slime) == heex
  end

  test "function components work with assigns when called with full module name" do
    slime = ":MyApp.module.city name=city_name"
    heex = "<MyApp.module.city name={city_name}/>"
    assert precompile(slime) == heex
  end

  test "function components work with assigns and inner_block when called with full module name" do
    slime = ~S"""
    :MyApp.module.city name=city_name
      div
        | test
    """

    heex = "<MyApp.module.city name={city_name}><div>test</div></MyApp.module.city>"
    assert precompile(slime) == heex
  end

  test "function components work with forms" do
    slime = ~S"""
    :MyApp.module.city name=city_name :let=f
      div
        | test
    """

    heex = "<MyApp.module.city name={city_name} :let={f}><div>test</div></MyApp.module.city>"
    assert precompile(slime) == heex
  end

  test "rest attribute" do
    slime = ~S"""
    div[id="123" @rest]
      | test
    """

    heex = "<div id=\"123\" {@rest}>test</div>"
    assert precompile(slime) == heex
  end

  test "function component with @ in attribute value" do
    slime = ":component[name=\"Name\" user=@user]"
    heex = "<.component name=\"Name\" user={@user}/>"
    assert precompile(slime) == heex
  end

  test "component attribute without value" do
    slime = """
    select
      option[value=""]
        | Test
    """

    heex = "<select><option value=\"\">Test</option></select>"

    assert precompile(slime) == heex
  end
end
