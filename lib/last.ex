defmodule Monadic.Last do
  @behaviour Monadic.Behaviour

  def bind(statement, context) do
    quote do
      unquote(last(context)) = (unquote(statement))
      unquote(context.continue(last(context)))
    end
  end

  defp last(context) do
    context.options[:last] || {:_last, [], nil}
  end
end