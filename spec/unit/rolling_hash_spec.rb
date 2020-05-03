module Mod
  WORD = (1 << 30) - 1
  LOW_HALFWORD  = (1 << 15) - 1
  HIGH_HALFWORD = WORD - LOW_HALFWORD

  def self.mul30(a, b)
    alo = a & LOW_HALFWORD
    blo = b & LOW_HALFWORD
    ahi = (a & HIGH_HALFWORD) >> 15
    bhi = (b & HIGH_HALFWORD) >> 15

    (
      (alo * blo) +
      ((ahi * blo & LOW_HALFWORD) << 15) +
      ((alo * bhi & LOW_HALFWORD) << 15)
    ) & WORD
  end

  def self.add30(a, b)
    a + b & WORD
  end

  def self.sub30(a, b)
    add30(a, -b)
  end
end

describe "fast modulo 2**30 multiplication" do
  it "works for small numbers" do
    expect(Mod.mul30(5, 3)).to eq 15
    expect(Mod.mul30(1001, 1001)).to eq 1002001
    expect(Mod.mul30(1001, 100001)).to eq 100101001
  end

  it "overflows at 2**30, preventing conversion to a Bignum" do
    expect(Mod.mul30(99451, 129538)).to eq 1_071_523_574
  end

  it "works with numbers near 2**30" do
    expect(Mod.mul30(1073726593, 1073735952)).to eq 89436432
  end
end

describe "fast 30-bit addition" do
  it "works for small numbers" do
    expect(Mod.add30(5, 3)).to eq 8
    expect(Mod.add30(1001, 220)).to eq 1221
  end

  it "overflows at 2**30" do
    expect(Mod.add30(2**30 - 1, 1)).to eq 0
  end

  it "underflows" do
    expect(Mod.add30(0, -1)).to eq 2**30 - 1
  end

  it "underflows with big operands" do
    expect(Mod.add30(0, -Mod::WORD)).to eq 1
  end
end

describe "subtraction" do
  it "works" do
    expect(Mod.sub30(5, 10)).to eq (Mod::WORD - 4)
  end
end


class RollingHash
  BASE = 69069
  TERMS = 8 # Number of terms of the polynomial.
  LAST_TERM_MULTIPLIER = (TERMS - 1).times.reduce(1) { |product, _| Mod.mul30(BASE, product) }
  BOUNDARY_MASK = 0b111111_11111100_00000000_00000000

  def initialize
    @hash = 0
    @ring_buffer = [0] * TERMS
    @ring_buffer_head_pos = 0
    [1, 2, 3, 4, 5, 6, 7, 8].each { |b| accept b }
  end

  def accept(byte)
    if byte > 255 || byte < 0
      raise "RollingHash can only accept values in the range 0-255; got #{byte}."
    end

    oldest_byte = overwrite_oldest_byte(byte)

    @hash = Mod.sub30(@hash, Mod.mul30(oldest_byte, LAST_TERM_MULTIPLIER))
    @hash = Mod.mul30(@hash, BASE) # effectively, shift terms left by 1
    @hash = Mod.add30(@hash, byte)
  end

  def chunk_boundary?
    @hash & BOUNDARY_MASK == 0
  end

  def hash
    @hash
  end

  private

  def overwrite_oldest_byte(new_byte)
    old = @ring_buffer[pos]
    @ring_buffer[pos] = new_byte
    advance
    old
  end

  def pos
    @ring_buffer_head_pos
  end

  def advance
    @ring_buffer_head_pos += 1
    @ring_buffer_head_pos = 0 if @ring_buffer_head_pos == TERMS
  end
end

describe RollingHash do
  it "accepts a new byte" do
    h = RollingHash.new
    h.accept 255
  end

  it "rejects values larger than 255" do
    h = RollingHash.new
    expect { h.accept 256 }.to raise_error "RollingHash can only accept values in the range 0-255; got 256."
  end

  it "rejects values less than 0" do
    h = RollingHash.new
    expect { h.accept -1 }.to raise_error "RollingHash can only accept values in the range 0-255; got -1."
  end

  it "does not report a chunk boundary when first initialized" do
    h = RollingHash.new
    expect(h.chunk_boundary?).to be false
  end

  it "sometimes reports a chunk boundaries" do
    h = RollingHash.new
    "beginning to ".bytes.each { |b| h.accept b }
    expect(h.chunk_boundary?).to be true
  end

  it "reports chunk boundaries independent of the text preceding the last 8 bytes before the boundary" do
    h = RollingHash.new
    "beginning to ".bytes.each { |b| h.accept b }
    expect(h.chunk_boundary?).to be true
    "planning to ".bytes.each { |b| h.accept b }
    expect(h.chunk_boundary?).to be true
  end

  it "usually does not report a chunk boundary" do
    h = RollingHash.new
    "eat your oatmeal!".bytes.each { |b| h.accept b }
    expect(h.chunk_boundary?).to be false
    "blemswitch harbor!".bytes.each { |b| h.accept b }
    expect(h.chunk_boundary?).to be false
  end

  it "computes the same hash if the last 8 bytes are the same" do
    h = RollingHash.new
    "blah 12345678".bytes.each { |b| h.accept b }
    hash1 = h.hash
    "foobar 12345678".bytes.each { |b| h.accept b }
    hash2 = h.hash
    expect(hash1).to eq hash2
  end

  it "finds a chunk boundary every so often" do
    h = RollingHash.new
    boundaries = []
    text = File.read File.join __dir__, "fixtures", "alice.txt"

    text.bytes.each_with_index do |b, index|
      h.accept b
      boundaries << index if h.chunk_boundary?
    end

    expect(boundaries.map { |i| text[i...i+15] }).to eq [
      " get very tired",
      "then hurried on",
      "burning with cu",
      "do cats eat bat",
    ]
  end

  it "finds most of the same chunk boundary even when the text is perturbed" do
    h = RollingHash.new
    boundaries = []

    text = File.read File.join __dir__, "fixtures", "zorgotron.txt"
    # sanity check
    expect(text).not_to include "Alice"
    expect(text).to include "ZORGOTRON THE DESTROYER"

    text.bytes.each_with_index do |b, index|
        h.accept b
        boundaries << index if h.chunk_boundary?
      end

    expect(boundaries.map { |i| text.bytes[i...i+15].pack('c*') }).to include *[
      " get very tired",
      "then hurried on",
      "burning with cu",
    ]
  end
end
