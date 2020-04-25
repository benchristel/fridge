class InMemoryStorage
  def initialize
    @revision = 0
    @values = Hash.new { "" }
  end

  def update(key, value)
    @revision += 1
    @values[key] = value
  end

  def revision
    @revision
  end

  def get(key)
    @values[key]
  end
end
