module Tickable

  def self.extended(klass)
    klass.instance_variable_set(:@tickers, [])
  end

  def tick
    @tickers.each do |meth|
      self.send(meth)
    end
  end

  def add_ticker(meth)
    @tickers << meth
  end

end