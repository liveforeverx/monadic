defmodule Monadic.Error do
  @behaviour Monadic.Behaviour

  def bind(context, statement) do
    quote do
      case (unquote(statement)) do
        unquote(clauses(context))
      end
    end
  end

  defp clauses(context) do
    (for pattern <- pattern(context), do: {:->, [], error_clause(pattern)})
      ++
    [{:->, [], success_clause(context)}]
  end

  defp error_clause(pattern) do
    [
      [quote do
        unquote(pattern) = _err
      end],
      quote do: _err
    ]
  end

  defp success_clause(context) do
    [
      [quote(do: __monadic_error_result__)],
      Monadic.Context.continue(context, quote(do: __monadic_error_result__))
    ]
  end

  defp pattern(context), do: context.options[:pattern] || [:error, quote(do: {:error, _})]
end
