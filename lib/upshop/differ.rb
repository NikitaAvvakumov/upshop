require "yaml"
require "rugged"

module Upshop
  module Differ
    DifferResult = Struct.new(:status, :message, :files)
    ERROR_STATUS = "error"
    OK_STATUS = "ok"

    class << self
      def get_changed_files
        result = DifferResult.new
        begin
          discover_repository
          get_last_deployed_commit
          # if successful, run a diff and return a list of changed files
          # else return an explanation of why diff could not be calculated
        rescue DifferError => e
          result.status = ERROR_STATUS
          result.message = e.message
        end
        result
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
          raise(KeyError) unless @commit
        rescue KeyError, NoMethodError
          raise DifferError, "Unable to parse last deployed commit from deploy_file"
        end
      end
    end
  end
end

class DifferError < StandardError
  def initialize(message="Uncaught error parsing diff")
    super
  end
end
