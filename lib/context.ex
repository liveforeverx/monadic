defmodule Monadic.Context do

  defstruct [monad: nil,
             options: [],
             statements: [],
             first: true,
             next: nil,
             state: nil]

  def transform(this) do
    %{default_continue!(this) | statements: chain(this).statements(this.options[:do])}
      |> exec_monad
  end

  def exec_monad(%unquote(__MODULE__){statements: []}), do: nil
  def exec_monad(%unquote(__MODULE__){statements: [statement | _]} = this) do
    this.monad.bind(this, statement)
  end

  def continue(this, output) do
    this.next.(this, output)
  end

  def default_continue!(this) do
    %__MODULE__{this | next: &default_continue/2}
  end

  def default_continue(%unquote(__MODULE__){statements: [_]}, output) do
    output
  end

  def default_continue(%unquote(__MODULE__){statements: [_ | rest]} = this, output) do
    %__MODULE__{this | first: false, statements: rest}
      |> chain_statement(output)
      |> exec_monad
  end

  def chain_statement(%unquote(__MODULE__){statements: [statement | rest]} = this, output) do
    %{this | statements: [
      chain(this).combine(output, statement) | rest
    ]}
  end

  def chain(this) do
    this.options[:chain] || Monadic.Statements
  end
end
