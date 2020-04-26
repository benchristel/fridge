class InMemoryStorage
  def initialize
    @revision = 0
    @revisions = [Hash.new { "" }]
  end

  def update(key, value)
    @revision += 1
    @revisions[@revision] ||= @revisions[@revision - 1].clone
    @revisions[@revision][key] = value
  end

  def revision
    @revision
  end

  def get(key, revision)
    @revisions[revision.to_i][key]
  end
end
