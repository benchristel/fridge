require "storage_factory"

describe StorageFactory do
  it "defaults to in-memory storage" do
    env = {}
    expect(StorageFactory.build(env)).to be_an InMemoryStorage
  end

  it "creates file storage if you ask for it" do
    FileUtils.rm_rf "/tmp/fridge-unit-test"
    env = {
      "FRIDGE_STORAGE_TYPE" => "file",
      "FRIDGE_STORAGE_DIR" => "/tmp/fridge-unit-test",
    }
    expect(StorageFactory.build(env)).to be_a FileStorage
  end

  it "creates the file storage with the right directory" do
    FileUtils.rm_rf "/tmp/fridge-unit-test"
    env = {
      "FRIDGE_STORAGE_TYPE" => "file",
      "FRIDGE_STORAGE_DIR" => "/tmp/fridge-unit-test",
    }
    expect(StorageFactory.build(env)).to eq FileStorage.new("/tmp/fridge-unit-test")
  end

  it "errors if you ask for file storage without specifying a directory" do
    env = {
      "FRIDGE_STORAGE_TYPE" => "file",
    }
    expect { StorageFactory.build(env) }
      .to raise_error "FRIDGE_STORAGE_TYPE=file requires FRIDGE_STORAGE_DIR to be set."
  end

  it "creates in-memory storage if you ask for it" do
    env = {
      "FRIDGE_STORAGE_TYPE" => "memory",
    }
    expect(StorageFactory.build(env)).to be_an InMemoryStorage
  end

  it "errors if it doesn't know what you mean" do
    env = {
      "FRIDGE_STORAGE_TYPE" => "fhqwhgads",
    }
    expect { StorageFactory.build(env) }
      .to raise_error 'Unrecognized FRIDGE_STORAGE_TYPE "fhqwhgads". Options are "file", "memory".'
  end
end
