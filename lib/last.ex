defmodule Monadic.Last do
  @behaviour Monadic.Behaviour

  def bind(context, statement) do
    quote do
      unquote(last(context)) = (unquote(statement))
      unquote(Monadic.Context.continue(context, last(context)))
    end
  end

  defp last(context) do
    context.options[:last] || {:_last, [], nil}
  end
end
