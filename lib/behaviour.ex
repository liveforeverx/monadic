defmodule Monadic.Behaviour do
  use Behaviour

  defcallback bind(statement :: any, context :: Monadic.Context.t)
end