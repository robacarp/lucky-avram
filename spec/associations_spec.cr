require "./spec_helper"

describe Avram::Model do
  describe "has_many" do
    it "gets the related records" do
      post = PostBox.create
      post2 = PostBox.create
      comment = CommentBox.new.post_id(post.id).create

      post = Post::BaseQuery.new.find(post.id)

      post.comments.should eq [comment]
      comment.post.should eq post
      post2.comments.size.should eq 0
    end

    it "gets the related records for nilable association that exists" do
      manager = ManagerBox.create
      employee = EmployeeBox.new.manager_id(manager.id).create
      customer = CustomerBox.new.employee_id(employee.id).create

      manager = Manager::BaseQuery.new.find(manager.id)

      manager.employees.to_a.should eq [employee]
      employee.manager.should eq manager
      employee.customers.should eq [customer]
      manager.customers.should eq [customer]
    end

    it "returns nil for nilable association that doesn't exist" do
      employee = EmployeeBox.create
      employee.manager.should eq nil
    end

    it "accepts a foreign_key" do
      user = UserBox.create
      cred_1 = SignInCredentialBox.new.user_id(user.id).create
      cred_2 = SignInCredentialBox.new.user_id(user.id).create

      key_holder = KeyHolderQuery.new.first

      key_holder.sign_in_credentials.should eq [cred_1, cred_2]
    end
  end

  describe "has_many through" do
    it "joins the two associations" do
      tag = TagBox.create
      post = PostBox.create
      post2 = PostBox.create
      TagBox.create
      TaggingBox.new.tag_id(tag.id).post_id(post.id).create

      post.tags.should eq [tag]
      post2.tags.size.should eq 0
    end

    it "counts has_many through belongs_to associations" do
      tag = TagBox.create
      post = PostBox.create
      TagBox.create
      TaggingBox.new.tag_id(tag.id).post_id(post.id).create

      post.tags_count.should eq 1
    end

    it "counts has_many through has_many associations" do
      manager = ManagerBox.create
      employee = EmployeeBox.new.manager_id(manager.id).create
      CustomerBox.new.employee_id(employee.id).create

      manager.customers_count.should eq 1
    end
  end

  describe "has_one" do
    context "missing association" do
      it "raises if association is not nilable" do
        credentialed = AdminBox.create
        expect_raises Exception, "Could not find first record in sign_in_credentials" do
          credentialed.sign_in_credential
        end
      end

      it "returns nil if association is nilable" do
        possibly_credentialed = UserBox.create
        possibly_credentialed.sign_in_credential.should be_nil
      end
    end

    context "existing association" do
      it "returns associated model" do
        user = UserBox.create
        credentials = SignInCredentialBox.new.user_id(user.id).create
        user.sign_in_credential.should eq credentials
      end
    end
  end

  context "uuid backed models" do
    describe "has_one" do
      it "returns associated model" do
        item = LineItemBox.create
        price = PriceBox.new.line_item_id(item.id).create
        item.price.should eq price
      end
    end

    describe "belongs_to" do
      it "returns associated model" do
        item = LineItemBox.create
        price = PriceBox.new.line_item_id(item.id).create
        price.line_item.should eq item
      end

      it "returns associated model when using 'table' and 'foreign_key'" do
        post = PostWithCustomTable::SaveOperation.create!(title: "foo")
        comment = CommentForCustomPost::SaveOperation.create!(body: "bar", post_id: post.id)
        comment.post_with_custom_table.should eq(post)

        CommentForCustomPost::BaseQuery.new.where_post_with_custom_table(PostWithCustomTable::BaseQuery.new.id(post.id)).first.should eq(comment)
        PostWithCustomTable::BaseQuery.new.where_comments_for_custom_post(CommentForCustomPost::BaseQuery.new.id(comment.id)).first.should eq(post)
      end
    end

    describe "has_many" do
      it "gets the related records" do
        item = LineItemBox.create
        scan = ScanBox.new.line_item_id(item.id).create

        LineItemQuery.new.find(item.id).scans.should eq [scan]
      end

      it "gets amount of records" do
        item = LineItemBox.create
        ScanBox.new.line_item_id(item.id).create

        item.scans_count.should eq 1
      end
    end

    describe "has_many through a join table" do
      it "gets the related records" do
        item = LineItemBox.create
        scan = ScanBox.new.line_item_id(item.id).create

        LineItemQuery.new.find(item.id).scans.should eq [scan]
      end
    end
  end
end
