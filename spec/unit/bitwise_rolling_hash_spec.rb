class PrimeModulus
  def initialize(mod)
    @modulus = mod
  end

  def add(a, b)
    # assumption: a and b are both > 0 and < modulus
    sum = a + b
    if a + b > @modulus
      sum -= @modulus
    end
    sum
  end

  def subtract(a, b)
    # assumption: a and b are both > 0 and < modulus
    diff = a - b
    if diff < 0
      diff += @modulus
    end
    diff
  end

  def double(a)
    add(a, a)
  end
end

class RingBuffer
  def initialize(size, fill)
    @buffer = size.times.map { fill }
    @pos = 0
  end

  def overwrite_oldest(new)
    oldest = @buffer[@pos]
    @buffer[@pos] = new
    @pos += 1
    @pos = 0 if @pos == @buffer.size
    oldest
  end
end

class BitwiseRollingHash
  PRIME = 8117
  BITS = 64
  MOD = PrimeModulus.new(PRIME)
  MULTIPLIERS = (BITS - 1).times.reduce([1]) { |multipliers, _|
    multipliers.concat([MOD.double(multipliers.last)])
  }
  HIGH_TERM_MULTIPLIER = (BITS - 1).times.reduce(1) { |product, _| MOD.double product }
  SINGLE_BIT_MASKS = [
    0b1000_0000,
    0b0100_0000,
    0b0010_0000,
    0b0001_0000,
    0b0000_1000,
    0b0000_0100,
    0b0000_0010,
    0b0000_0001
  ]

  def initialize
    @hash = 0
    @ring = RingBuffer.new(BITS, 0)
    mod = PrimeModulus.new(PRIME)
    accept_string "initial8"
  end

  def hash
    @hash
  end

  def accept_string(s)
    s.bytes.each { |byte| accept byte }
    @hash
  end

  def accept(byte)
    each_bit(byte) { |b| accept_bit b }
    @hash
  end

  def accept_bit(b)
    old = @hash
    # Out with the old; in with the new.
    # Negate the effect of the oldest bit we remember
    oldest_bit = @ring.overwrite_oldest(b)
    puts oldest_bit
    @hash = MOD.subtract(@hash, HIGH_TERM_MULTIPLIER * oldest_bit)

    # The mad hatter wants a clean cup.
    # All the bits move one to the left.
    @hash = MOD.double(@hash)

    # incorporate the new bit
    @hash = MOD.add(@hash, b)
  end

  private

  def each_bit(byte)
    SINGLE_BIT_MASKS.each do |mask|
      yield (mask & byte == 0 ? 1 : 0)
    end
  end
end

describe BitwiseRollingHash do
  xit "changes the hash when accepting a byte" do
    hash1 = subject.accept 27
    hash2 = subject.accept 27
    expect(hash1).not_to eq hash2
  end

  it "zeroes out the hash given 8 zero bytes" do
    8.times { subject.accept 0 }
    expect(subject.hash).to eq 0
  end

  xit "computes the hash based only on the last 8 bytes" do
    hash1 = subject.accept_string "hello world"
    hash2 = subject.accept_string "hello world"
    expect(hash1).to eq hash2
  end
end
