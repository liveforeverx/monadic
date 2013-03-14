defmodule Monadic.Dispatch do
  def statements({:__block__, _context, statement}), do: collect(statement)
  def statements(other), do: collect(other)

  def combine(left, {method, args}) do
    quote do
      (unquote(left)).unquote(method)(unquote_splicing(args))
    end
  end

  defp collect({{:., _, [object, method]}, _, args}) do
    collect(object) ++ [{method, args}]
  end

  defp collect(final) do
    [final]
  end
end