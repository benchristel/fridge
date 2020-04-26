require "revision"

describe Revision do
  it "can't be blank" do
    expect(Revision.parse("", 0)).to be_a Revision::Malformed
  end

  it "can't contain non-numeric characters" do
    expect(Revision.parse("a1", 0)).to be_a Revision::Malformed
    expect(Revision.parse("1a", 0)).to be_a Revision::Malformed
  end

  it "can be 0" do
    expect(Revision.parse("0", 0)).to eq Revision::Valid.new(0)
  end

  it "ignores leading zeroes" do
    expect(Revision.parse("09", 10)).to eq Revision::Valid.new(9)
    expect(Revision.parse("00", 10)).to eq Revision::Valid.new(0)
  end

  it "can't be negative" do
    expect(Revision.parse("-1", 0)).to be_a Revision::Malformed
  end

  it "can't be greater than the current version" do
    expect(Revision.parse("1", 0)).to be_a Revision::Nonexistent
  end

  it "can be equal to the current version" do
    expect(Revision.parse("1", 1)).to eq Revision::Valid.new(1)
  end

  it "can have multiple digits" do
    expect(Revision.parse("1234567", 1234568))
      .to eq Revision::Valid.new(1234567)
  end

  it "can have a *lot* of digits" do
    expect(Revision.parse("11111111111111111111", 999999999999999999999))
      .to eq Revision::Valid.new(11111111111111111111)
  end
end
