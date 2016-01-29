require "yaml"
require "rugged"

module Upshop
  module Differ
    DifferResult = Struct.new(:status, :message, :deltas)
    ERROR_STATUS = "error"
    OK_STATUS = "ok"

    class << self
      def get_changed_files
        @result = DifferResult.new
        begin
          discover_repository
          get_last_deployed_commit
          determine_diff
        rescue DifferError => e
          @result.status = ERROR_STATUS
          @result.message = e.message
        end
        @result
      end

      private

      def get_last_deployed_commit
        deploy_file = get_deploy_file
        extract_last_deployed_commit_from deploy_file
      end

      def discover_repository
        begin
          @repo = Rugged::Repository.new("./")
        rescue Rugged::RepositoryError
          raise DifferError, "Unable to find git repository in current folder"
        end
      end

      def get_deploy_file
        begin
          deploy_file = YAML.load_file("deploy_file.yml")
        rescue Errno::ENOENT
          raise DifferError, "Unable to find deploy_file"
        end
      end

      def extract_last_deployed_commit_from(file)
        begin
          @commit = file[:deploys][0].fetch(:commit)
          raise(DifferError) unless @repo.exists?(@commit)
        rescue KeyError, NoMethodError, TypeError, DifferError
          raise DifferError, "No valid last deployed commit found in deploy_file"
        end
      end

      def determine_diff
        head = @repo.head.target
        last_deploy = @repo.lookup(@commit)
        diff = last_deploy.diff(head)
        deltas = diff.deltas.map do |delta|
          { path: delta.new_file[:path], status: delta.status }
        end

        @result.status = OK_STATUS
        @result.deltas = deltas
      end
    end
  end
end

class DifferError < StandardError
  def initialize(message="Uncaught error parsing diff")
    super
  end
end
