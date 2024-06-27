defmodule Slime.Sigil do
  @doc """
  Provides the `~h` sigil with HTML safe Slime HEEX syntax inside source files.

      iex> import Slime.Sigil
      iex> assigns = %{w: "world"}
      iex> ~l"\""
      ...> p = "hello " <> @w
      ...> "\""
      {:safe, ["<p>", "hello world", "</p>"]}
  """

  defmacro sigil_h({:<<>>, meta, [expr]}, []) do
    unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
      raise "~H requires a variable named \"assigns\" to exist and be set to a map"
    end

    expr = Slime.Renderer.precompile(expr)

    options = [
      engine: Phoenix.LiveView.TagEngine,
      file: __CALLER__.file,
      line: __CALLER__.line + 1,
      caller: __CALLER__,
      indentation: meta[:indentation] || 0,
      source: expr,
      tag_handler: Phoenix.LiveView.HTMLEngine
    ]

    EEx.compile_string(expr, options)
  end
end
