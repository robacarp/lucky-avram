require "../spec_helper"

include LazyLoadHelpers

describe "Enum" do
  it "check enum" do
    issue = IssueBox.create

    issue.status.enum.should eq(Issue::AvramStatus::Opened)
    issue.role.enum.should eq(Issue::AvramRole::Issue)
  end

  it "update enum" do
    issue = IssueBox.create

    updated_issue = Issue::SaveOperation.update!(issue, status: Issue::Status.new(:closed))

    updated_issue.status.enum.should eq(Issue::AvramStatus::Closed)
    updated_issue.role.enum.should eq(Issue::AvramRole::Issue)
  end

  it "access enum methods" do
    issue = IssueBox.create

    issue.status.opened?.should eq(true)
    issue.status.value.should eq(0)
  end

  it "access enum to_s and to_i" do
    issue = IssueBox.create

    issue.status.to_s.should eq("Opened")
    issue.status.to_i.should eq(0)
  end

  it "provides a working ==" do
    Issue::Status.new(:closed).should eq(Issue::Status.new(:closed))
    Issue::Status.new(:opened).should_not eq(Issue::Status.new(:closed))
  end

  it "provides enum-like constant values" do
    Issue::Status::Closed.should eq(Issue::Status.new(:closed).enum)
    Issue::Status.new(:closed).enum.should eq(Issue::Status::Closed)
  end

  it "implements case equality" do
    case Issue::Status.new(:closed).value
    when Issue::Status.new(:closed)
      true
    else
      false
    end.should be_true

    case Issue::Status::Closed.value
    when Issue::Status.new(:closed)
      true
    else
      false
    end.should be_true

    case Issue::Status.new(:opened).value
    when Issue::Status::Opened
      true
    else
      false
    end.should be_true

    case Issue::Status::Opened.value
    when Issue::Status::Opened
      true
    else
      false
    end.should be_true
  end
end
