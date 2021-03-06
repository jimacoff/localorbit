module ProductImport
  module Formats
    class Csv
      def enum_for(filename:, **rest)
        Enumerator.new do |yielder|
          require 'csv'

          CSV.foreach(filename) do |row|
            yielder << row
          end
        end
      end
    end
  end
end
