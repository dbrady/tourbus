require 'csv'

class TourBus
  class CsvFeeder < Feeder
    def initialize(options)
      @data = CSV.read(options['file'], headers: true)
    end
    def get_example
      index = if @data.length == 1
                0
              elsif @data.length > 1
                rand(@data.length - 1)
              else
                raise ArgumentError.new("CsvFeeder#get_example: there should be at least 1 line with data")
              end
      @data[index]
    end
  end
end
