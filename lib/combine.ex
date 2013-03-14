defmodule Monadic.Combine do
  @behaviour Monadic.Behaviour

  def bind(statement, context) do
    if (
      not is_list(context.options[:combine]) ||
      length(context.options[:combine]) < 1
    ) do
      throw("invalid combine options")
    end

    next(statement, context.state(context.options[:combine]))
  end

  def next(output, Monadic.Context[state: [current | rest]] = context) do
    current.bind(output,
      context.
        state(rest).
        next(function(__MODULE__, :next, 2))
    )
  end

  def next(output, context) do
    context.
      default_continue!.
      continue(output)
  end
end