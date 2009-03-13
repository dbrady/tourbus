#!/usr/bin/env ruby

# Sketch code for formatters.
# include "matt_formatter"

class Formatter
  require 'rubygems'
  require 'fox16'
  include Fox

  attr_reader :runners, :runs, :tours, :tests

  def fixed_font(app, pt=8)
    font = FXFont.new(app, "courier", pt)
    font.create
    font
  end
  
  def hilite(r=200, g=130, b=130)
    style = FXHiliteStyle.new 
    style.normalForeColor = FXRGB(g, r, b)
    style
  end
  
  def indicator(event)
    { :pass => '.',
      :fail => 'F',
      :error => 'E',
      :pending => 'P'
    }[event] || '?'
  end
  
  def color(name)
    unless @colors
      @colors = {
        :fail => hilite(255,0,0),
        :pass => hilite(0,255,0),
        :pending => hilite(255, 165, 0), # orange
        :error => hilite(128, 0, 128) # purple
      }
    end
    @colors[name] || hilite(0,0,0)
  end
  
  def getStyle(event)
    event ? [:pass, :fail, :pending, :error].index(event)+1 : 0
  end
  
  def make_modal_popup(app, title='Tourbus', content="Click me!")
    modal = FXMessageBox.new(
      app, title, content, nil, MBOX_OK|DECOR_TITLE|DECOR_BORDER
    )
    modal.execute
  end
  
  def initialize(runners, runs, tours, tests)
    tests_total = runners * runs * tests
    danceMonkeyDance(runners, runs, tours, tests, tests_total)
  end
  
  ###
  #
  # Portions of the visual layout
  #
  ###
  
  def buildHorseRace(parent, runners)
    horses = []
    FXScrollWindow.new(parent, LAYOUT_FIX_X|LAYOUT_FIX_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, 0, 25, 800, 250) do |scroll|
      @frame = FXVerticalFrame.new(scroll, LAYOUT_FILL)
      1.upto(runners) do |r|
        FXHorizontalFrame.new(@frame, LAYOUT_FILL|LAYOUT_FIX_HEIGHT, 0, 0, 0, 20) do |line|
          FXLabel.new(line, r.to_s)
          FXText.new(line, nil, 0, TEXT_READONLY|LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH|TEXT_AUTOSCROLL, 0, 0, 745, 20) do |horse|
            horse.font = fixed_font(@mainApp, 12)
            horse.hiliteStyles = [color(:fail), color(:pass), color(:pending), color(:error)]
            horse.styled = 1
            horses[r] = horse
          end
        end
      end
    end
    horses
  end
  
  def buildLogWindow(parent)
    log = FXText.new(parent, nil, 0, TEXT_READONLY|TEXT_SHOWACTIVE|LAYOUT_FIX_X|LAYOUT_FIX_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, 0, 300, 800, 270)
    log.font = fixed_font(@mainApp, 8)
    log.hiliteStyles = [color(:fail), color(:pass), color(:pending), color(:error)]
    log.styled = 1
    log
  end
  
  def buildTourDetails(parent, tests_total, runners, runs, tests, tours)
    FXHorizontalFrame.new(parent, LAYOUT_FILL|LAYOUT_FIX_HEIGHT, 0, 0, 0, 25) do |status|
      FXLabel.new(status,  tests_total.to_s + ' total to run')
      FXLabel.new(status, 'Runners: ' + runners.to_s)
      FXLabel.new(status, 'Runs: ' + runs.to_s)
      FXLabel.new(status, 'Tests per runner: ' + tests.to_s)
      FXLabel.new(status, 'Tours: ' + tours.join(', ').to_s)
    end
  end
  
  def buildExitButton(parent)
    FXHorizontalFrame.new(parent, LAYOUT_FIX_Y|LAYOUT_FIX_X|LAYOUT_FIX_HEIGHT, 765, 0, 0, 25) do |more_buttons|
      FXButton.new(more_buttons, 'Exit') do |exit_button|
        exit_button.connect(SEL_COMMAND) do
          if @tourbus_is_finished
            @we_are_finished = true
          else
            make_modal_popup(@mainApp, nil, "Tourbus has not finished, can't exit until it finishes.")
          end
        end
      end
    end
  end
  
  ###
  #
  # Main: build the app itself, called by initialize()
  #
  ###
  
  def danceMonkeyDance(runners, runs, tours, tests, tests_total)
    @mainApp = FXApp.new

    mainWindow = FXMainWindow.new(@mainApp, 'Tourbus')
    mainWindow.width=800; mainWindow.height=600
    mainLayout = FXVerticalFrame.new(mainWindow, LAYOUT_FILL)

    @we_are_finished = false; @tourbus_is_finished = false
    @stats = Hash.new(0)
    @stats_fields = {}
    
    buildTourDetails(mainLayout, tests_total, runners, runs, tests, tours)
    
    @horses = buildHorseRace(mainLayout, runners)
    
    FXHorizontalFrame.new(mainLayout, LAYOUT_FIX_Y|LAYOUT_FIX_HEIGHT|FRAME_RAISED, 0, 275, 0, 25) do |buttons|
      FXLabel.new(buttons, "Showing: ")
      @current_filter_field = FXTextField.new(buttons, 5, nil, 0, TEXT_READONLY|LAYOUT_FIX_HEIGHT, 0, 0, 0, 20)
      @current_filter_field.text = 'All'
      %w[All Fail Pending Error].each do |filter|
        FXButton.new(buttons, filter) do |r|
          r.connect(SEL_COMMAND) do
            unless @current_filter_field == r
              @log_window.setText(nil)
              @current_filter_field.text = filter
              ['Fail', 'Pending', 'Error'].include?(filter) ?
                @log_buffer.each { |l|  @log_window.appendText(l[1]+"\n") if l[0].to_s == filter.downcase } :
                @log_buffer.each { |l|  @log_window.appendStyledText(l[1]+"\n", getStyle(l[0])) }
            end
          end
        end
      end
    end
    
    buildExitButton(mainLayout)

    @log_buffer = []     
    @log_window = buildLogWindow(mainLayout)
    
    FXHorizontalFrame.new(mainLayout, LAYOUT_FIX_Y|LAYOUT_FIX_HEIGHT|FRAME_RAISED, 0, 570, 0, 30) do |counts|
      FXLabel.new(counts, 'Total completed: ')
      @stats_fields[:complete] = count_text_field(counts, tests_total.to_s.size)
      FXLabel.new(counts, '/'+tests_total.to_s)
      FXLabel.new(counts, 'Passes: ')
      @stats_fields[:pass] = count_text_field(counts, tests_total.to_s.size)
      FXLabel.new(counts, 'Fails: ')
      @stats_fields[:fail] = count_text_field(counts, tests_total.to_s.size)
      FXLabel.new(counts, 'Errors: ')
      @stats_fields[:error] = count_text_field(counts, tests_total.to_s.size)
      FXLabel.new(counts, 'Pendings: ')
      @stats_fields[:pending] = count_text_field(counts, tests_total.to_s.size)
    end

    @mainApp.create    
    mainWindow.show
    
    # must thread the run because .run doesn't return control until exit
    Thread.new do
      @mainApp.run
    end
  end
  
  def count_text_field(parent, size=5)
    FXTextField.new(parent, size, nil, 0, TEXT_READONLY|LAYOUT_FIX_HEIGHT, 0, 0, 0, 20)
  end
  
  ###
  #
  # called from tourbus, indicating the tour is complete
  #
  ###
  
  def shutdown
      @tourbus_is_finished = true
      report_message = ''
      %w[complete pass fail error pending].each do |s|
        report_message << "#{s}: #{@stats[s.intern] || 0}  "
      end
      make_modal_popup(@mainApp, 'Run Synopsis', report_message)
  end
  
  ###
  #
  # Lets tourbos know the gui has finished and it is OK to kill it
  #
  ###
  
  def finished; @we_are_finished; end
  
  ###
  #
  # called from Tourbus directly to record tour events
  #
  ###
  
  def log(msg, event=nil)
    @log_buffer << [event, msg]
    @log_window.appendStyledText(msg + "\n", getStyle(event))
    @log_window.makePositionVisible(@log_window.rowStart(@log_window.getLength))
  end
  def appendField(field, text, style)
    field.appendStyledText(text, getStyle(style))
    field.makePositionVisible(field.getLength)
    @stats[:complete] += 1
    @stats_fields[:complete].text = @stats[:complete].to_s
  end
  
  def increment_count_and_horse(event, runner, message)
    appendField(@horses[runner+1], indicator(event), event)
    @stats[event] += 1
    @stats_fields[event].text = @stats[event].to_s
    log message, event    
  end
  
  def test_passed(runner, test_name)
    increment_count_and_horse(:pass, runner, "PASSED: runner #{runner}, test '#{test_name}'")
  end
  def test_failed(runner, test_name, msg)
    increment_count_and_horse(:fail, runner, "FAILED: runner #{runner}, test '#{test_name}': Message: #{msg}")
  end
  def test_pending(runner, test_name, msg)
    increment_count_and_horse(:pending, runner, "PENDING: runner #{runner}, test '#{test_name}': Message: #{msg}")
  end
  def test_errored(runner, test_name, err)
    increment_count_and_horse(:error, runner, "ERROR: runner #{runner}, test '#{test_name}': Message: #{err}")
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
          if outcome <= 90
            @formatter.test_passed runner, test_name
          elsif outcome <= 95
            @formatter.test_pending runner, test_name, "#{test_name} PENDING. (Waiting for code that doesn't pend.)"
          elsif outcome <= 97
            @formatter.test_failed runner, test_name, "#{test_name} FAILED. Should have worked, but didn't."
          else
            @formatter.test_errored runner, test_name, "#{test_name} BLEW THE FREAK UP. Should have worked, but OMG WHY AM I ON FIRE"
          end
          @formatter.log "Finished test #{test_name}"
          # sleep(rand * 0.01)
        end
        @formatter.log "Runner #{run}: Finished tour #{tour}"
      end
      @formatter.log "Finished run #{run} of #{RUNS_PER_RUNNER}"
    end
  end
  
  threads.each {|t| t.join }
end

@formatter.shutdown()
while !@formatter.finished; sleep(1); end
