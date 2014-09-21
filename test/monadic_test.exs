defmodule MonadicTest do
  use ExUnit.Case
  import Monadic

  test "error" do
    assert (monadic :error, do: :a) == :a
    assert (monadic :error do
      :a
      :b
      :c
    end) == :c

    assert (monadic :error do
      :a
      :error
      :c
    end) == :error

    assert (monadic :error do
      :a
      {:error, 1}
      :c
    end) == {:error, 1}

    assert (monadic :error, pattern: [:b] do
      :a
      :b
      :c
    end) == :b

    a = 2
    assert (monadic :error, pattern: [:a, ^a] do
      1
      2
      3
    end) == 2
  end

  test "error_pipe" do
    assert (monadic :error, chain: :pipeline, do: :a) == :a

    assert (monadic :error, chain: :pipeline do
      1 |>
      (fn(x) -> x + 1 end).() |>
      (fn(x) -> x * 3 end).()
    end) == 6

    assert (monadic :error, chain: :pipeline do
      1 |>
      (fn(_) -> :error end).() |>
      (fn(x) -> x * 3 end).()
    end) == :error

    assert (monadic :error, chain: :pipeline do
      1 |>
      (fn(_) -> :error end).() |>
      (fn(x) -> x * 3 end).()
    end) == :error
  end


  defmodule TestClass do
    def new, do: {__MODULE__, 0}

    def inc({__MODULE__, 3}), do: :error
    def inc({__MODULE__, any}), do: {__MODULE__, any + 1}

    def inc(x, {__MODULE__, any}), do: {__MODULE__, any + x}

    def get({__MODULE__, value}), do: value
  end

  test "dispatch error" do
    assert (monadic :error, chain: :dispatch do
      TestClass.new.inc(2).inc.get
    end) == 3

    assert (monadic :error, chain: :dispatch do
      TestClass.new.inc(2).inc.inc.inc.get
    end) == :error
  end


  test "last" do
    assert (monadic :last do
      :sets.new
      :sets.add_element(:a, _last)
      :sets.add_element(:b, _last)
      :sets.add_element(:b, _last)
      :sets.add_element(:c, _last)
      :sets.to_list(_last)
    end) == [:a, :b, :c]

    assert (monadic last: last do
      :sets.new
      :sets.add_element(:a, last)
      :sets.add_element(:b, last)
      :sets.add_element(:b, last)
      :sets.add_element(:c, last)
      :sets.to_list(last)
    end) == [:a, :b, :c]
  end

  test "hygienic" do
    monadic last: last, do: 1
    assert last == 1

    monadic last: last, hygienic: true, do: 2
    assert last == 1
  end

  test "combine" do
    assert (monadic combine: [:error, :last] do
      1
      _last + 2
      _last + 3
    end) == 6

    assert (monadic combine: [:error, :last], last: last do
      1
      last + 2
      :error
      last + 3
    end) == :error
    assert last == 3
  end

  test "state" do
    assert (monadic state: state do
      set {:b, 1}
      set x = {:a, state + 1}
      state = state + 2
      set y = {:c, state * 3}
      {x,y}
    end) == {:a, :c}

    assert state == 12
  end

end
