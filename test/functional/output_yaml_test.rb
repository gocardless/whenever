require 'test_helper'

class OutputYaml < Whenever::TestCase
  test "with output_format => yaml" do
    output = Whenever.cron :output_format => :yaml, :string => \
    <<-file
      every 2.hours do
        command "blahblah"
      end
    file

    assert_equal(
      {
        "version" => 1,
        "crons" => [
          {
            "name" => nil,
            "command" => "/bin/bash -l -c 'blahblah'",
            "timezone" => "UTC",
            "team" => "unknown",
            "retryable" => false,
            "frequency" => two_hours
          }
        ]
      },
      YAML.load(output)
    )
  end

  test "specifying job_name, timezone, team and retryable" do
    output = Whenever.cron :output_format => :yaml, :string => \
    <<-file
      every 2.hours do
        command "launch-rocket",
                job_name: "launch-rocket",
                timezone: "BST",
                team: "core-infrastructure",
                retryable: true
      end
    file

    assert_equal(
      {
        "version" => 1,
        "crons" => [
          {
            "name" => "launch-rocket",
            "command" => "/bin/bash -l -c 'launch-rocket'",
            "timezone" => "BST",
            "team" => "core-infrastructure",
            "retryable" => true,
            "frequency" => two_hours
          }
        ]
      },
      YAML.load(output)
    )
  end
end
