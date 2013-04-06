# Monadic

Programmatic control over multiple statements, inspired by the monad pattern, but not an exact implementation of the concept. Monadic decorates each statement in compile time which allows greater flexibility.

## Provided monads

### Error monad

Executes statements in succession, stops if a statement returns an error. By default treats `:error` and `{:error, _}` as errors, and everything else as success:

```elixir
import Monadic
...

monadic :error do
  1
  2
  3
end == 3

monadic :error do
  some_fun(...)
  :error
  another_fun(...)
end == :error
```

Error pattern can be customized:

```elixir
monadic :error, pattern: [:b] do
  some_fun(...)
  :b    # recognized as error
  another_fun(...)
end == :b
```

### Last monad

Stores the result of each statement in the _\_last_ variable:

```elixir
monadic :last do
  :sets.new
  :sets.add_element(:a, _last)
  :sets.add_element(:b, _last)
  :sets.add_element(:c, _last)
  :sets.to_list(_last)
end
```

The name of the variable holding last result can be configured:

```elixir
monadic last: last do
  :sets.new
  :sets.add_element(:a, last)
  :sets.add_element(:b, last)
  :sets.add_element(:c, last)
  :sets.to_list(last)
end
```

### State monad

Helps chaining functions which return a tuple in the form of {response, state}

```elixir
monadic :state do
  set {:a, 1}             # ignores result (:a), stores 1 to state
  set foo = {:b, 2}       # stores :b to foo, 2 to state
  _state = 3              # custom state setting
  _state = _state + 1     # _state can be referenced anywhere in expression
  IO.puts "foo"           # doesn't affect state
  foo                     # last expression is returned
end
```

The name of the variable holding the state can be configured:

```elixir
monadic state: state do
  ...
end
```


### Combine monad

```elixir
monadic combine: [:error, :last] do
  1
  _last + 2
  :error
  _last + 3
end == :error

_last == 3    # the result of the last successful operation
```

In this example, each statement is first decorated with the error monad, and then with the last monad.

## Chaining

By default, monadic iterates over multiple statements. This can be configured via _chain_ parameter:

```elixir
monadic :error, chain: :pipeline do
  x |>
  somefun(...) |> 
  another_fun(...)
end

monadic :error, chain: :dispatch do
  x.
    some_fun(...).
    another_fun(...)
end
```

Alternative chainings don't always make sense. The last monad is not meaningful in this context (since the last result is passed anyway). The state monad also won't work. The combine monad might work, but I didn't test it.

## Hygiene

By default, monadic generates unhygienic code. Everything you create inside lives outside the monadic scope. In addition, the last monad automatically creates the \_last variable. If you want to confine the monad to its own isolated scope, you can use the _hygienic_ option:

```elixir
monadic :last, hygienic: true, do
  ...
end
```

This will wrap the entire code in an anonymous lambda and execute it.

## Custom monads

You can use your own monads:

```elixir
monadic MyMonad do
  ...
end
```

Here, _MyMonad_ is a module which must implement _Monadic.Behaviour_.  
See the code of the exising monads as a reference. The simplest one is _Monadic.Last_.
