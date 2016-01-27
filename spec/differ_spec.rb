require 'spec_helper'

RSpec.describe Upshop::Differ do
  describe "get_changed_files" do
    context "when last deployed commit can be determined" do
      context "when file diff can be determined" do
        example do

        end
      end

      context "when file diff cannot be determined" do
        example do

        end
      end
    end

    context "when last deployed commit cannot be determined" do
      context "when deploy_file does not exist" do
        example do
          expected_response = "Unable to find deploy_file"
          allow(YAML).to receive(:load_file).and_raise Errno::ENOENT

          expect(Upshop::Differ.get_changed_files).to eq expected_response
        end
      end

      context "when last deployed commit cannot be parsed from deploy_file" do
        example do
          expected_response = "Unable to parse last deployed commit from deploy_file"
          allow(YAML).to receive(:load_file).and_return({ deploys: [] })

          expect(Upshop::Differ.get_changed_files).to eq expected_response
        end
      end
    end
  end
end
