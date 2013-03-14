defmodule Monadic.Error do
  @behaviour Monadic.Behaviour

  def bind(statement, context) do
    quote do
      case (unquote(statement)) do
        unquote(clauses(context))
      end
    end
  end

  defp clauses(context) do
    {:"->", [], error_clauses(context) ++ [success_clause(context)]}
  end

  defp error_clauses(context) do
    lc pattern inlist pattern(context) do
      {
        [quote do
          unquote(pattern) = _err
        end],
        quote do: _err
      }
    end
  end

  defp success_clause(context) do
    {
      [quote(do: __monadic_error_result__)],
      context.continue(quote(do: __monadic_error_result__))
    }
  end

  defp pattern(context), do: context.options[:pattern] || [:error, quote(do: {:error, _})]
end
