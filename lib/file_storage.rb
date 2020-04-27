require "fileutils"
require "digest"
require "json"

class FileStorage < Struct.new(:dir)
  def initialize(dir)
    super
    @revision_file = File.join dir, "revision"
    @revisions_dir = File.join dir, "revisions"
    @content_dir   = File.join dir, "content"

    FileUtils.mkdir_p @content_dir
    File.write @revision_file, "0"
    write_mkdir_p File.join(@revisions_dir, "0"), write_content(JSON({}))
  end

  def update(key, value)
    content_digest = write_content value
    new_index_digest = update_index(key, content_digest)
    new_revision = revision + 1
    File.write revision_path(new_revision), new_index_digest
    File.write @revision_file, "#{new_revision}"
    new_revision
  end

  def revision
    File.read(@revision_file).to_i
  end

  def get(key, revision)
    content_digest = look_up_in_index(key, revision.to_i)
    if content_digest
      read_content content_digest
    else
      ""
    end
  end

  private

  def update_index(key, content_digest)
    key_digest = digest key
    index = index_for revision
    index[key_digest] = content_digest
    write_content JSON index
  end

  def look_up_in_index(key, revision)
    key_digest = digest key
    index = index_for revision
    index[key_digest]
  end

  def write_content(value)
    content_digest = digest value
    path = content_path content_digest
    write_mkdir_p path, value
    content_digest
  end

  def index_for(revision)
    index_digest = File.read File.join @revisions_dir, revision.to_s
    JSON.parse read_content index_digest
  end

  def read_content(digest)
    File.read File.join content_path digest
  end

  def revision_path(revision)
    File.join(@revisions_dir, "#{revision}")
  end

  def content_path(digest)
    File.join @content_dir, digest[0...2], digest[2...4], digest
  end

  def digest(s)
    Digest::SHA1.hexdigest s
  end

  def write_mkdir_p(path, content)
    FileUtils.mkdir_p File.dirname path
    File.write path, content
  end
end
