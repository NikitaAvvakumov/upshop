require 'spec_helper'
require 'ostruct'

DIFFER = Upshop::Differ
RESULT = Upshop::Differ::DifferResult

RSpec.describe Upshop::Differ do
  describe "get_delta" do

    describe "happy path" do
      example do
        delta1 = OpenStruct.new(
          old_file: {:oid=>"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391", :path=>"first.file", :size=>0, :flags=>12, :mode=>33188},
          new_file: {:oid=>"0000000000000000000000000000000000000000", :path=>"first.file", :size=>0, :flags=>4, :mode=>0},
          similarity: 0,
          status: :deleted
        )
        delta2 = OpenStruct.new(
          old_file: {:oid=>"0000000000000000000000000000000000000000", :path=>"fourth.file", :size=>0, :flags=>4, :mode=>0},
          new_file: {:oid=>"2e9dd1e5cfa3e1c78a73bb13eef76192f274919d", :path=>"fourth.file", :size=>0, :flags=>12, :mode=>33188},
          similarity: 0,
          status: :added
        )
        delta3 = OpenStruct.new(
          old_file: {:oid=>"e69de29bb2d1d6434b8b29ae775ad8c2e48c5391", :path=>"second.file", :size=>0, :flags=>12, :mode=>33188},
          new_file: {:oid=>"2e9dd1e5cfa3e1c78a73bb13eef76192f274919d", :path=>"second.file", :size=>0, :flags=>12, :mode=>33188},
          similarity: 0,
          status: :modified
        )
        diff = OpenStruct.new(deltas: [delta1, delta2, delta3])

        commit = double("commit", diff: diff)
        repo = double("repo", :exists? => true, lookup: commit)
        allow(repo).to receive_message_chain(:head, :target)
        allow(Rugged::Repository).to receive(:new).and_return repo
        deploys = [{ commit: "12345" }]
        allow(YAML).to receive(:load_file).and_return({ deploys: deploys })

        deltas = [
          { path: "first.file", status: :deleted },
          { path: "fourth.file", status: :added },
          { path: "second.file", status: :modified }
        ]
        expected_response = RESULT.new("ok", nil, deltas)

        expect(DIFFER.get_delta).to eq expected_response
      end
    end

    describe "sad paths" do
      describe "discover_repository" do
        context "when repo is not discovered" do
          example do
            allow(Rugged::Repository).to receive(:new).and_raise Rugged::RepositoryError
            expected_response = RESULT.new("error",
                                           "Unable to find git repository in current folder")

            expect(DIFFER.get_delta).to eq expected_response
          end
        end
      end

      describe "get_last_deployed_commit" do
        before(:each) { allow(Rugged::Repository).to receive(:new) }

        context "when last deployed commit cannot be determined" do
          context "when deploy_file does not exist" do
            example do
              allow(YAML).to receive(:load_file).and_raise Errno::ENOENT
              expected_response = RESULT.new("error",
                                             "Unable to find deploy_file")

              expect(DIFFER.get_delta).to eq expected_response
            end
          end

          context "when last deployed commit cannot be parsed from deploy_file" do
            example do
              allow(YAML).to receive(:load_file).and_return({ deploys: [] })
              expected_response = RESULT.new("error",
                                             "No valid last deployed commit found in deploy_file")

              expect(DIFFER.get_delta).to eq expected_response
            end
          end

          context "when last deployed commit is nil" do
            example do
              deploys = [{ commit: nil }]
              allow(YAML).to receive(:load_file).and_return({ deploys: deploys })
              expected_response = RESULT.new("error",
                                             "No valid last deployed commit found in deploy_file")

              expect(DIFFER.get_delta).to eq expected_response
            end
          end

          context "when commit SHA1 cannot be found in repo" do
            example do
              repo = double("repo")
              allow(repo).to receive(:exists?).with("12345").and_return false
              allow(Rugged::Repository).to receive(:new).and_return repo
              deploys = [{ commit: "12345" }]
              allow(YAML).to receive(:load_file).and_return({ deploys: deploys })

              expected_response = RESULT.new("error",
                                             "No valid last deployed commit found in deploy_file")

              expect(DIFFER.get_delta).to eq expected_response
            end
          end
        end
      end
    end
  end
end
