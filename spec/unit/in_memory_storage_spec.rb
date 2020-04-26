require "in_memory_storage"
require_relative "contracts/storage.rb"

describe InMemoryStorage do
  it_behaves_like "storage"
end
