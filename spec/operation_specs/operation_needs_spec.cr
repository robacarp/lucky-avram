require "../spec_helper"

private class OperationWithNeeds < Avram::Operation
  needs tags : Array(String)
  needs id : Int32
  attribute title : String
  attribute published : Bool = false

  def run
    tags.join(", ")
  end
end

describe "Avram::Operation needs", focus: true do
  it "sets up named args on run" do
    OperationWithNeeds.run(tags: ["one", "two"], id: 3) do |operation, value|
      value.should eq "one, two"
      operation.tags.should eq ["one", "two"]
      operation.id.should eq 3
    end
  end
end