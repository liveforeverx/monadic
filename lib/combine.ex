defmodule Monadic.Combine do
  @behaviour Monadic.Behaviour

  def bind(context, statement) do
    if (
      not is_list(context.options[:combine]) ||
      length(context.options[:combine]) < 1
    ) do
      throw("invalid combine options")
    end

    next(%{context | state: context.options[:combine]}, statement)
  end

  def next(%Monadic.Context{state: [current | rest]} = context, output) do
    %{context | state: rest, next: &__MODULE__.next/2}
      |> current.bind(output)
  end

  def next(context, output) do
    context
      |> Monadic.Context.default_continue!
      |> Monadic.Context.continue(output)
  end
end
