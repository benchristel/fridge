require "fileutils"
require "digest"

class FileStorage < Struct.new(:dir)
  def initialize(dir)
    super
    @revision_file = File.join dir, "revision"
    @revisions_dir = File.join dir, "revisions"
    @content_dir   = File.join dir, "content"

    FileUtils.mkdir_p @revisions_dir
    FileUtils.mkdir_p @content_dir
    File.write @revision_file, "0"
    File.write File.join(@revisions_dir, "0"), write_content(JSON({}))
  end

  def update(key, value)
    content_digest = write_content value
    key_digest = digest key
    old_index_digest = File.read File.join @revisions_dir, revision.to_s
    index = JSON.parse(read_content old_index_digest)
    index[key_digest] = content_digest
    new_index_digest = write_content JSON index
    File.write File.join(@revisions_dir, "#{revision + 1}"), new_index_digest

    File.write @revision_file, "#{revision + 1}"
  end

  def revision
    File.read(@revision_file).to_i
  end

  def get(key, revision)
    key_digest = digest key
    index_digest = File.read File.join @revisions_dir, revision.to_s
    index = JSON.parse(read_content index_digest)
    content_digest = index[key_digest]
    if content_digest
      read_content content_digest
    else
      ""
    end
  end

  private

  def write_content(value)
    content_digest = digest value

    dir = File.join @content_dir, content_digest[0...2], content_digest[2...4]
    path = File.join dir, content_digest

    FileUtils.mkdir_p dir
    File.write path, value

    content_digest
  end

  def read_content(digest)
    path = File.join @content_dir, digest[0...2], digest[2...4], digest
    File.read(path)
  end

  def digest(s)
    Digest::SHA1.hexdigest s
  end
end
