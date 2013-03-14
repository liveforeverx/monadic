defmodule Monadic.Pipeline do
  def statements({:__block__, _context, statement}), do: collect(statement)
  def statements(other), do: collect(other)

  def combine(left, right) do
    quote do
      (unquote(left)) |> unquote(right)
    end
  end

  defp collect(statement), do: collect(statement, [])

  defp collect({:|>, _, [left, right]}, acc) do
    collect(right, acc ++ [left])
  end

  defp collect(final, acc) do
    acc ++ [final]
  end
end