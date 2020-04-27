shared_examples_for "storage" do
  it "increments the revision ID when you update a key" do
    expect { subject.update("the-key", "the-value") }
      .to change { subject.revision }.by(1)
  end

  it "returns the new revision ID from an update" do
    expect(subject.update("the-key", "the-value"))
      .to be 1
  end

  it "returns an empty string if you get a nonexistent key" do
    expect(subject.get("blah", 0)).to eq ""
  end

  it "converts revisions to integers" do
    rev_one = double :revision, to_i: 1
    subject.update("foo", "hi")
    expect(subject.get("foo", rev_one)).to eq "hi"
  end

  it "gets the value for a key at the current revision" do
    subject.update("the-key", "one")
    expect(subject.get("the-key", subject.revision)).to eq "one"
    subject.update("the-key", "two")
    expect(subject.get("the-key", subject.revision)).to eq "two"
  end

  it "gets the value for a key at a previous revision" do
    rev_one = subject.update("the-key", "one")
    subject.update("the-key", "two")
    expect(subject.get("the-key", rev_one)).to eq "one"
  end

  it "stores multiple keys with different values" do
    subject.update("one", "1")
    subject.update("two", "2")
    expect(subject.get("one", subject.revision)).to eq "1"
    expect(subject.get("two", subject.revision)).to eq "2"
  end

  it "gets the value of a key at a revision between updates" do
    subject.update("ones", "11")
    rev_two = subject.update("twos", "22")
    subject.update("ones", "1111")

    expect(subject.get("ones", rev_two)).to eq "11"
  end
end
