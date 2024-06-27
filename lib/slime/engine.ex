defmodule Slime.Engine do
  @moduledoc """
  The Engine that powers `.heex` templates and the `~H` sigil.

  It works by adding a HTML parsing and validation layer on top
  of `Phoenix.HTML.TagEngine`.
  """

  @behaviour Phoenix.Template.Engine

  @impl Phoenix.Template.Engine
  def compile(path, _name) do
    source = read!(path)

    EEx.compile_string(source,
      engine: Phoenix.LiveView.TagEngine,
      line: 1,
      file: path,
      trim: true,
      caller: __ENV__,
      source: source,
      tag_handler: Phoenix.LiveView.HTMLEngine
    )
  end

  @behaviour Phoenix.LiveView.TagEngine

  @impl Phoenix.LiveView.TagEngine
  def handle_attributes(ast, meta),
    do: Phoenix.LiveView.HTMLEngine.handle_attributes(ast, meta)

  @impl Phoenix.LiveView.TagEngine
  def annotate_caller(file, line),
    do: Phoenix.LiveView.HTMLEngine.annotate_caller(file, line)

  @impl Phoenix.LiveView.TagEngine
  def annotate_body(%Macro.Env{} = caller),
    do: Phoenix.LiveView.HTMLEngine.annotate_body(caller)

  @impl Phoenix.LiveView.TagEngine
  def classify_type(":" <> name), do: {:slot, String.to_atom(name)}
  def classify_type(":inner_block"), do: {:error, "the slot name :inner_block is reserved"}

  def classify_type(<<first, _::binary>> = name) when first in ?A..?Z,
    do: {:remote_component, String.to_atom(name)}

  def classify_type("." <> name),
    do: {:local_component, String.to_atom(name)}

  def classify_type(name), do: {:tag, name}

  @impl Phoenix.LiveView.TagEngine
  for void <- ~w(area base br col hr img input link meta param command keygen source) do
    def void?(unquote(void)), do: true
  end

  def void?(_), do: false

  defp read!(file_path) do
    file_path
    |> File.read!()
    |> Slime.Renderer.precompile()
  end
end
