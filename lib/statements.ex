defmodule Monadic.Statements do
  def statements({:__block__, _context, lines}), do: lines
  def statements(list) when is_list(list), do: list
  def statements(other), do: [other]

  def combine(_, right) do
    quote do
      unquote(right)
    end
  end
end