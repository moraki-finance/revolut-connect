RSpec.describe Revolut::Resource do
  let(:resource_path) { "test_resources" }

  before do
    stub_const("Revolut::Resource::TestResource", Class.new(Revolut::Resource))
    Revolut::Resource::TestResource.class_eval do
      def self.resources_name
        "test_resources"
      end
    end
  end

  describe "#create" do
    let(:payload) { {name: "Test"} }

    before do
      allow(Revolut::Client.instance).to receive(:post).with("/#{resource_path}", data: payload).and_return(
        OpenStruct.new(body: {"id" => 1, "name" => "Test"})
      )
    end

    it "creates a resource and returns its instance" do
      resource = Revolut::Resource::TestResource.create(name: "Test")

      expect(resource).to be_a(Revolut::Resource::TestResource)
      expect(resource.id).to eq(1)
      expect(resource.name).to eq("Test")
    end
  end

  describe "#retrieve" do
    it "retrieves a resource by id and returns its instance" do
      allow(Revolut::Client.instance).to receive(:get).with("/#{resource_path}/1").and_return(
        OpenStruct.new(body: {"id" => 1, "name" => "Test"})
      )

      resource = Revolut::Resource::TestResource.retrieve(1)

      expect(resource).to be_a(Revolut::Resource::TestResource)
      expect(resource.id).to eq(1)
      expect(resource.name).to eq("Test")
    end
  end

  describe "#update" do
    it "updates a resource by id and returns its instance" do
      data = {name: "Updated"}

      allow(Revolut::Client.instance).to receive(:patch).with("/#{resource_path}/1", data:).and_return(
        OpenStruct.new(body: {"id" => 1, "name" => "Updated"})
      )

      resource = Revolut::Resource::TestResource.update(1, name: "Updated")

      expect(resource).to be_a(Revolut::Resource::TestResource)
      expect(resource.id).to eq(1)
      expect(resource.name).to eq("Updated")
    end
  end

  describe "#delete" do
    it "deletes a resource by id" do
      allow(Revolut::Client.instance).to receive(:delete).with("/#{resource_path}/1").and_return(true)

      expect(Revolut::Resource::TestResource.delete(1)).to be true
    end
  end

  describe "#list" do
    it "lists resources" do
      allow(Revolut::Client.instance).to receive(:get).with("/#{resource_path}").and_return(
        OpenStruct.new(body: [{"id" => 1, "name" => "Test"}])
      )

      resources = Revolut::Resource::TestResource.list
      resource = resources.first

      expect(resource).to be_a(Revolut::Resource::TestResource)
      expect(resource.id).to eq(1)
      expect(resource.name).to eq("Test")
    end
  end

  describe "#to_proc" do
    it "coerces the object passed in" do
      resources = [{"id" => 1, "name" => "Test"}].map(&Revolut::Resource::TestResource)
      resource = resources.first

      expect(resource).to be_a(Revolut::Resource::TestResource)
      expect(resource.id).to eq(1)
      expect(resource.name).to eq("Test")
    end
  end

  describe "#skip_coertion_for" do
    before do
      stub_const("Revolut::Resource::SkipCoerceResource", Class.new(Revolut::Resource))
      Revolut::Resource::SkipCoerceResource.class_eval do
        skip_coertion_for :object
      end
    end

    it "skips the recursive coertion of the passed in attributes" do
      result = Revolut::Resource::SkipCoerceResource.new({
        id: 1,
        object: {id: 2}
      })

      expect(result.object).to eq({id: 2})
    end
  end

  describe "#coerce_with" do
    before do
      stub_const("Revolut::Resource::CoerceWithResource", Class.new(Revolut::Resource))
      Revolut::Resource::CoerceWithResource.class_eval do
        coerce_with object: Revolut::Resource::TestResource
      end
    end

    it "coerces the attributes with the passed in resources" do
      result = Revolut::Resource::CoerceWithResource.new({
        id: 1,
        object: {id: 2}
      })
      expect(result.object).to be_a(Revolut::Resource::TestResource)
    end
  end

  describe "#not_allowed_to" do
    before do
      stub_const("Revolut::Resource::NotAllowedToResource", Class.new(Revolut::Resource))
      Revolut::Resource::NotAllowedToResource.class_eval do
        not_allowed_to :update

        def self.resources_name
          "not_allowed_to"
        end
      end
    end

    it "raises an exception when trying to execute a forbidden method" do
      expect {
        Revolut::Resource::NotAllowedToResource.update(1, name: "Test")
      }.to raise_error(Revolut::UnsupportedOperationError, "`update` operation is not allowed on this resource")
    end

    it "succeeds to execute an allowed method" do
      allow(Revolut::Client.instance).to receive(:get).with("/not_allowed_to/1").and_return(
        OpenStruct.new(body: {"id" => 1, "name" => "Updated"})
      )

      expect {
        Revolut::Resource::NotAllowedToResource.retrieve(1)
      }.not_to raise_error
    end
  end

  describe "#only" do
    before do
      stub_const("Revolut::Resource::OnlyResource", Class.new(Revolut::Resource))
      Revolut::Resource::OnlyResource.class_eval do
        only :update

        def self.resources_name
          "only_resources"
        end
      end
    end

    it "raises an exception when trying to execute a forbidden method" do
      expect {
        Revolut::Resource::OnlyResource.retrieve(1)
      }.to raise_error(Revolut::UnsupportedOperationError, "`retrieve` operation is not allowed on this resource")
    end

    it "succeeds to execute an allowed method" do
      allow(Revolut::Client.instance).to receive(:patch).with("/only_resources/1", data: {name: "Test"}).and_return(
        OpenStruct.new(body: {"id" => 1, "name" => "Updated"})
      )

      expect {
        Revolut::Resource::OnlyResource.update(1, name: "Test")
      }.not_to raise_error
    end
  end

  describe "#shallow" do
    before do
      stub_const("Revolut::Resource::ShallowResource", Class.new(Revolut::Resource))
      Revolut::Resource::ShallowResource.class_eval do
        shallow
      end
    end

    it "sets the only array as empty" do
      expect(Revolut::Resource::ShallowResource.send(:only)).to eq([:shallow])
    end

    it "raises an exception when trying to execute a forbidden method" do
      expect {
        Revolut::Resource::ShallowResource.retrieve(1)
      }.to raise_error(Revolut::UnsupportedOperationError, "`retrieve` operation is not allowed on this resource")
    end
  end

  describe ".to_json" do
    it "returns the json representation of the resource" do
      payload = {id: 1, name: "Test"}
      expect(Revolut::Resource::TestResource.new(payload).to_json).to eq payload.to_json
    end
  end

  describe "#new" do
    it "coerces the attributes with the passed in resources" do
      result = Revolut::Resource::TestResource.new({
        id: 1,
        string: "hey",
        object: {id: 2},
        array_of_strings: ["a", "b"],
        array_of_objects: [{id: 3, name: "Test"}, {id: 4}]
      })
      expect(result.id).to eq 1
      expect(result.string).to eq "hey"
      expect(result.array_of_strings).to eq ["a", "b"]
      expect(result.array_of_objects.first).to be_a Revolut::Resource
      expect(result.array_of_objects.first).to have_attributes(id: 3, name: "Test")
    end
  end

  describe "#resources_name" do
    before do
      stub_const("Revolut::Resource::NoResources", Class.new(Revolut::Resource))
    end

    it "raises an exception" do
      expect {
        Revolut::Resource::NoResources.send(:resources_name)
      }.to raise_error(Revolut::NotImplementedError, "Implement #resources_name in subclass")
    end
  end
end
