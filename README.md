# Monadic

Programmatic control over multiple statements, inspired by the monad pattern, but not an exact implementation of the concept. Monadic decorates each statement in compile time which allows greater flexibility.

## Provided monads

### Error monad

Executes statements in succession, stops if a statement returns an error. By default treats `:error` and `{:error, _}` as errors, and everything else as success:

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

Error pattern can be customized:

    monadic :error, pattern: [:b] do
      some_fun(...)
      :b    # recognized as error
      another_fun(...)
    end == :b

### Last monad

Stores the result of a statement in the _\_last_ variable:

    monadic :last do
      :sets.new
      :sets.add_element(:a, _last)
      :sets.add_element(:b, _last)
      :sets.add_element(:c, _last)
      :sets.to_list(_last)
    end

The name of the variable holding last result can be configured:

    monadic last: last do
      :sets.new
      :sets.add_element(:a, last)
      :sets.add_element(:b, last)
      :sets.add_element(:c, last)
      :sets.to_list(last)
    end


### Combine monad

    monadic combine: [:error, :last] do
      1
      _last + 2
      :error
      _last + 3
    end == :error

    _last == 3    # the result of the last successful operation

In this example, each statement is first decorated with the error monad, and then with the last monad.

## Chaining

By default, monadic iterates over multiple statements. This can be configured via _chain_ parameter:

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

Alternative chainings don't always make sense. The last monad is not meaningful in this context (since the last result is passed anyway). The combine monad might work, but I didn't test it.

## Hygiene

By default, monadic generates unhygienic code. Everything you create inside lives outside the monadic scope. In addition, the last monad automatically creates the \_last variable. If you want to confine the monad in a separate scope, you can use the _hygienic_ option:

    monadic :last, hygienic: true, do
      ...
    end

This will wrap the entire code in an anonymous lambda and execute it.

## Custom monads

You use your own monads:

    monadic MyMonad do
      ...
    end

Here, _MyMonad_ is a module which must implement _Monadic.Behaviour_.  
See the code of the exising monads as a reference. The simplest one is _Monadic.Last_.