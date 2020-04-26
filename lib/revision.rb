class Revision
  DIGITS = /^[0-9]+$/

  def self.parse(raw_revision, latest_revision)
    case raw_revision
    in nil
      Valid.new latest_revision
    in DIGITS if raw_revision.to_i <= latest_revision
      Valid.new raw_revision.to_i
    in DIGITS
      Nonexistent.new
    else
      Malformed.new
    end
  end

  Valid = Struct.new(:to_i)
  Nonexistent = Class.new
  Malformed = Class.new
end
