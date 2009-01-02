class HashProxy
  def initialize(options = {})
    @set = options[:set]
    @get = options[:get]
  end

  def [](key); @get && @get.call(key); end
  def []=(key, value); @set && @set.call(key, value); end
end