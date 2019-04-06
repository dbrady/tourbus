require 'csv'

class TourBus
  class CsvFeeder < Feeder
    def initialize(options)
      @data = CSV.read(options['file'], headers: true)
    end
    def get_example
      @data[rand(@data.length - 1)]
    end
  end
end
