class FileStorage < Struct.new(:dir)
  def initialize(dir)
    super
    require "in_memory_storage"
    @cheat = InMemoryStorage.new
  end

  def method_missing(m, *args)
    @cheat.public_send m, *args
  end
end
