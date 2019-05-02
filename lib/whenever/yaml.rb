# frozen_string_literal: true

require "yaml"

module Whenever
  module Output
    # Generates cron config in an extended YAML format:
    # ---
    # version: 1
    # crons:
    #   - frequency: "1,2 * * * *"
    #     name: Jobs::SomeJob
    #     timezone: UTC
    #     command: bin/rails runner 'JobRunner::Runner.new(Jobs::SomeJob).run'
    #     team: core-infrastructure
    #     retryable: true
    class Yaml
      # TODO: validate timezone
      def self.output_job(time, job)
        {
          name: job.options[:job_name],
          command: job.output,
          frequency: Whenever::Output::Cron.new(time).time_in_cron_syntax,
          timezone: job.options.fetch(:timezone, 'UTC'),
          team: job.options.fetch(:team, :unknown).to_s,
          retryable: job.options.fetch(:retryable, false)
        }.transform_keys(&:to_s)
      end

      # @param [Hash<time, Array<Job>>]
      def self.output(jobs_per_time)
        crons = jobs_per_time[:default_mailto].flat_map do |time, jobs|
          jobs.map { |job| output_job(time, job) }
        end

        YAML.dump("version" => 1, "crons" => crons)
      end
    end
  end
end
