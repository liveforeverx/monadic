defmodule Monadic do
  defmacro monadic(monad, options, do: block) do
    transform(monad, Keyword.put(options, :do, block), __CALLER__)
  end

  defmacro monadic(options, [do: block = {:__block__, _, _}]) when is_list(options) do
    transform(monad(options), Keyword.put(options, :do, block), __CALLER__)
  end

  defmacro monadic(monad, options) do
    transform(monad, options, __CALLER__)
  end

  defmacro monadic(options) when is_list(options) do
    transform(monad(options), options, __CALLER__)
  end

  defp transform(monad, options, caller) do
    context = %Monadic.Context{
      monad: parse_monad(monad, caller),
      options: parse_options(options, caller)
    }

    do_transform(options[:hygienic], context)
  end

  defp parse_options(options, caller) do
    options |>
    Keyword.put(:chain, parse_chain(options[:chain], caller)) |>
    Keyword.put(:combine, parse_combine(options[:combine], caller))
  end

  defp parse_combine([h | t], caller) do
    [parse_monad(h, caller) | parse_combine(t, caller)]
  end

  defp parse_combine(other, _), do: other

  defp do_transform(true, context) do
    quote do
      (fn() -> unquote(Monadic.Context.transform(context)) end).()
    end
  end

  defp do_transform(_, context) do
    quote do
      (unquote(Monadic.Context.transform(context)))
    end
  end

  defp monad(options) do
    cond do
      Keyword.get(options, :combine) != nil -> :combine
      Keyword.get(options, :last) != nil -> :last
      Keyword.get(options, :state) != nil -> :state
      true -> throw("cannot determine monad")
    end
  end

  defp parse_monad({:__aliases__, _, _} = module, caller) do
    Macro.expand(module, caller)
  end

  defp parse_monad(:error, _), do: Monadic.Error
  defp parse_monad(:last, _), do: Monadic.Last
  defp parse_monad(:state, _), do: Monadic.State
  defp parse_monad(:combine, _), do: Monadic.Combine
  defp parse_monad(other, _), do: other

  defp parse_chain({:__aliases__, _, _} = module, caller) do
    Macro.expand(module, caller)
  end

  defp parse_chain(:pipeline, _), do: Monadic.Pipeline
  defp parse_chain(:dispatch, _), do: Monadic.Dispatch

  defp parse_chain(nil, _), do: Monadic.Statements
end
