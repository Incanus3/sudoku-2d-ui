module Sudoku
  module UI
    class Output
      def self.for(widget:)
        new(widget)
      end

      def initialize(widget)
        @widget = widget
      end

      def puts(message)
        @widget.text = message
      end

      def p(thing)
        @widget.text = thing.inspect
      end

      alias << puts
    end
  end
end
