class InMemoryStorage
  def initialize
    @revision = 0
  end

  def update
    @revision += 1
  end

  def revision
    @revision
  end
end
