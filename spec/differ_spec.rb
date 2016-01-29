require 'spec_helper'

DIFFER = Upshop::Differ
RESULT = Upshop::Differ::DifferResult

RSpec.describe Upshop::Differ do
  describe "get_changed_files" do

    describe "sad paths" do
      describe "discover_repository" do
        context "when repo is not discovered" do
          example do
            allow(Rugged::Repository).to receive(:new).and_raise Rugged::RepositoryError
            expected_response = RESULT.new("error",
                                           "Unable to find git repository in current folder")

            expect(DIFFER.get_changed_files).to eq expected_response
          end
        end
      end

      describe "get_last_deployed_commit" do
        before(:each) { allow(Rugged::Repository).to receive(:new) }

        context "when file diff cannot be determined" do
          example do

          end
        end
      end

      context "when last deployed commit cannot be determined" do
        context "when deploy_file does not exist" do
          example do
            allow(YAML).to receive(:load_file).and_raise Errno::ENOENT
            expected_response = RESULT.new("error",
                                           "Unable to find deploy_file")

            expect(DIFFER.get_changed_files).to eq expected_response
          end
        end

        context "when last deployed commit cannot be parsed from deploy_file" do
          example do
            allow(YAML).to receive(:load_file).and_return({ deploys: [] })
            expected_response = RESULT.new("error",
                                           "Unable to parse last deployed commit from deploy_file")

            expect(DIFFER.get_changed_files).to eq expected_response
          end
        end

        context "when last deployed commit is nil" do
          example do
            deploys = [{ commit: nil, date: "some date" }]
            allow(YAML).to receive(:load_file).and_return({ deploys: deploys })
            expected_response = RESULT.new("error",
                                           "Unable to parse last deployed commit from deploy_file")

            expect(DIFFER.get_changed_files).to eq expected_response
          end
        end
      end
    end
  end
end
