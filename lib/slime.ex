defmodule Slime do
  @moduledoc """
  Slim-like HTML templates.
  """

  alias Slime.Renderer

  defmodule TemplateSyntaxError do
    @moduledoc """
    Syntax exception which may appear during parsing and compilation processes
    """
    defexception [:line, :line_number, :column, message: "Syntax error", source: "INPUT"]

    def message(exception) do
      column = if exception.column == 0, do: 0, else: exception.column - 1

      """
      #{exception.message}
      #{exception.source}, Line #{exception.line_number}, Column #{exception.column}
      #{exception.line}
      #{String.duplicate(" ", column)}^
      """
    end
  end

  defdelegate render(slime), to: Renderer
  defdelegate render(slime, bindings), to: Renderer
end
