module Sudoku
  module UI
    class MainWindow
      module Events
        class Event
          def initialize(*_args, **_kwargs)
            # this is defined so that we can add initialize params later and not break Liskov
          end
        end

        Dummy = Class.new(Event)

        class CellClicked < Event
          attr_reader :cell

          def initialize(cell)
            @cell = cell
          end
        end

        class ButtonClicked < Event
          attr_reader :button

          def initialize(button)
            @button = button
          end
        end

        class CellFilled < Event
          attr_reader :finished

          def initialize(finished)
            @finished = finished
          end
        end
      end
    end
  end
end
