require "file_storage"
require_relative "contracts/storage.rb"

describe FileStorage do
  subject { FileStorage.new "/tmp/fridge-file-storage-tests" }

  it_behaves_like "storage"
end
