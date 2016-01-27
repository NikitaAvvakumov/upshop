require "yaml"

module Upshop
  module Differ
    class << self
      def get_changed_files
        begin
          get_last_deployed_commit
          # if successful, run a diff and return a list of changed files
          # else return an explanation of why diff could not be calculated
        rescue DifferError => e
          e.message
        end
      end

      def get_last_deployed_commit
        deploy_file = get_deploy_file
        extract_last_deployed_commit_from deploy_file
      end

      private

      def get_deploy_file
        begin
          deploy_file = YAML.load_file("deploy_file.yml")
        rescue Errno::ENOENT
          raise DifferError, "Unable to find deploy_file"
        end
      end

      def extract_last_deployed_commit_from(file)
        begin
          file[:deploys][0].fetch(:commit)
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
