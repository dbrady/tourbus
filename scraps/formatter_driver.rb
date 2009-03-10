#!/usr/bin/env ruby

# Sketch code for formatters.
# include "matt_formatter"

class Formatter
  attr_reader :runners, :runs, :tours, :tests
  def initialize(runners, runs, tours, tests)
  end
  def log(msg)
    puts msg
  end
  def test_passed(runner, test_name)
    log "PASSED: runner #{runner}, test '#{test_name}'"
  end
  def test_failed(runner, test_name, msg)
    log "FAILED: runner #{runner}, test '#{test_name}': Message: #{msg}"
  end
  def test_pending(runner, test_name, msg)
    log "PENDING: runner #{runner}, test '#{test_name}': Message: #{msg}"
  end
  def test_errored(runner, test_name, err)
    log "PASSED: runner #{runner}, test '#{test_name}': Message: #{err}"
  end
end

# Runners is the number of concurrent testing processes to run at once;
# Runners will perform a Run of all tours the same number of repetitions;
# Each Run has some number of tours, and
# Each tour has some number of tests.

RUNNERS = 10
RUNS_PER_RUNNER = 5
TOURS = ["SimpleTour", "ComplicatedTour"]
TESTS_PER_TOUR = {"SimpleTour"=>2, "ComplicatedTour" => 10}

@formatter = Formatter.new RUNNERS, RUNS_PER_RUNNER, TOURS, TOURS.inject(0) {|a,b| a+TESTS_PER_TOUR[b]}


threads = []
RUNNERS.times do |runner|
  threads << Thread.new do
    1.upto(RUNS_PER_RUNNER) do |run|
      @formatter.log "Starting run #{run} of #{RUNS_PER_RUNNER}"
      TOURS.each do |tour|
        @formatter.log "Runner #{run}: Starting tour #{tour}"
        1.upto(TESTS_PER_TOUR[tour]) do |test|
          test_name = "test_test_#{run}_#{test}"
          @formatter.log "Beginning test #{test_name}"
          outcome = rand(100)
          if outcome <= 80
            @formatter.test_passed runner, test_name
          elsif outcome <= 88
            @formatter.test_pending runner, test_name, "#{test_name} PENDING. (Waiting for code that doesn't pend.)"
          elsif outcome <= 96
            @formatter.test_failed runner, test_name, "#{test_name} FAILED. Should have worked, but didn't."
          else
            @formatter.test_errored runner, test_name, "#{test_name} BLEW THE FREAK UP. Should have worked, but OMG WHY AM I ON FIRE"
          end
          @formatter.log "Finished test #{test_name}"
          sleep(rand * 0.01)
        end
        @formatter.log "Runner #{run}: Finished tour #{tour}"
      end
      @formatter.log "Finished run #{run} of #{RUNS_PER_RUNNER}"
    end
  end
  
  threads.each {|t| t.join }
end
