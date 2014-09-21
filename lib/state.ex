defmodule Monadic.State do
  @behaviour Monadic.Behaviour

  def bind(context, statement) do
    handle(context, statement)
  end

  defp handle(context, {:set, _, [{:=, _, [var, expr]}]}) do
    quote do
      {unquote(var), unquote(state_identifier(context))} = unquote(expr)
      unquote(Monadic.Context.continue(context, var))
    end
  end

  defp handle(context, {:set, _, [expr]}) do
    quote do
      {_last, unquote(state_identifier(context))} = unquote(expr)
      unquote(Monadic.Context.continue(context, quote(do: _last)))
    end
  end

  defp handle(context, other) do
    quote do
      _last = unquote(other)
      unquote(Monadic.Context.continue(context, quote(do: _last)))
    end
  end

  defp state_identifier(context) do
    context.options[:state] || {:_state, [], nil}
  end
end
