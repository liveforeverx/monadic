defmodule Monadic.State do
  @behaviour Monadic.Behaviour

  def bind(statement, context) do
    handle(statement, context)
  end
  
  defp handle({:set, _, [{:=, _, [var, expr]}]}, context) do
    quote do
      {unquote(var), unquote(state_identifier(context))} = unquote(expr)
      unquote(context.continue(var))
    end
  end
  
  defp handle({:set, _, [expr]}, context) do
    quote do
      {_last, unquote(state_identifier(context))} = unquote(expr)
      unquote(context.continue(quote(do: _last)))
    end
  end
  
  defp handle(other, context) do
    quote do
      _last = unquote(other)
      unquote(context.continue(quote(do: _last)))
    end
  end
  
  defp state_identifier(context) do
    context.options[:state] || {:_state, [], nil}
  end
end