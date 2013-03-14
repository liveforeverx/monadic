defrecord Monadic.Context, [
  :monad, :options, :statements, {:first, true}, :next, :state
] do
  
  def transform(this) do
    this.
      default_continue!.
      statements(this.chain.statements(this.options[:do])).
      exec_monad
  end
  
  def exec_monad(__MODULE__[statements: []]), do: nil
  def exec_monad(__MODULE__[statements: [statement | _]] = this) do
    this.monad.bind(statement, this)
  end

  def continue(output, this) do
    this.next.(output, this)
  end

  def default_continue!(this) do
    this.next(function(:default_continue, 2))
  end
  
  def default_continue(output, __MODULE__[statements: [_]]) do
    output
  end
  
  def default_continue(output, __MODULE__[statements: [_ | rest]] = this) do
    this.
      first(false).
      statements(rest).
      chain_statement(output).
      exec_monad
  end
  
  def chain_statement(output, __MODULE__[statements: [statement | rest]] = this) do
    this.statements([
      this.chain.combine(output, statement) |
      rest
    ])
  end
  
  def chain(this) do
    this.options[:chain] || Monadic.Statements
  end
end