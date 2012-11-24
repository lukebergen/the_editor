module Tickable

  def self.extended(klass)
    klass.instance_eval do
      @tickers = []
    end
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