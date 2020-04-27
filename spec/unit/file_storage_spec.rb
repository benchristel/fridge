require "fileutils"
require "file_storage"
require_relative "contracts/storage.rb"

describe FileStorage do
  STORAGE_DIR = "/tmp/fridge-file-storage-tests"
  before :each do
    FileUtils.rm_rf STORAGE_DIR
  end

  subject { FileStorage.new STORAGE_DIR }

  it "sets up a content-addressed revision 0" do
    subject
    expect(Set.new Dir["#{STORAGE_DIR}/**/*"])
      .to contain_exactly *[
        "#{STORAGE_DIR}/content",
        "#{STORAGE_DIR}/content/bf",
        "#{STORAGE_DIR}/content/bf/21",
        "#{STORAGE_DIR}/content/bf/21/bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f",
        "#{STORAGE_DIR}/revision",
        "#{STORAGE_DIR}/revisions",
        "#{STORAGE_DIR}/revisions/0",
      ]

    expect(File.read("#{STORAGE_DIR}/revisions/0"))
      .to eq "bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f"
    expect(File.read("#{STORAGE_DIR}/content/bf/21/bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f"))
      .to eq "{}"
  end

  it "reads empty values for all keys in revision 0" do
    expect(subject.get("foo", 0)).to eq ""
  end

  it "increments the revision number on update" do
    subject
    expect { subject.update("greeting", "Hello, world!") }
      .to change {
        File.read "#{STORAGE_DIR}/revision"
      }.from("0").to("1")
  end

  it_behaves_like "storage"
end
