defmodule Slime.Renderer do
  @moduledoc """
  Transform Slime templates into HTML.
  """
  alias Slime.Compiler
  alias Slime.Parser

  @doc """
  Compile Slime template to valid HEEx HTML.

  ## Examples
      iex> Slime.Renderer.precompile(~s(input.required type="hidden"))
      "<input class=\\"required\\" type=\\"hidden\\">"
  """
  def precompile(input) do
    input
    |> Parser.parse()
    |> Compiler.compile()
  end

  @doc """
  Takes a Slime template as a string as well as a set of bindings, and renders
  the resulting HTML.

  Note that this method of rendering is substantially slower than rendering
  precompiled templates created with Slime.function_from_file/5 and
  Slime.function_from_string/5.
  """

  def render(slime, bindings \\ []) do
    heex = precompile(slime)

    options = [
      engine: Phoenix.LiveView.TagEngine,
      file: __ENV__.file,
      line: __ENV__.line + 1,
      caller: __ENV__,
      indentation: 0,
      source: heex,
      tag_handler: Phoenix.LiveView.HTMLEngine
    ]

    heex
    |> EEx.eval_string([assigns: bindings], options)
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
  end
end
