class InMemoryStorage
  def initialize
    @revision = 0
    @revisions = [Hash.new { "" }]
  end

  def update(key, value)
    @revisions << @revisions.last.merge(key => value)
    @revision = @revisions.length - 1
  end

  def revision
    @revision
  end

  def get(key, revision)
    @revisions[revision.to_i][key]
  end
end
