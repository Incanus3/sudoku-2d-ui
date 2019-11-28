module Sudoku
  module UI
    class MainWindow
      module States
        class State
          def initialize(*_args, **_kwargs)
            # this is defined so that we can add initialize params later and not break Liskov
          end

          def text
            raise NotImplementedError
          end
        end

        class WaitingForCellSelection < State
          def text
            'select cell'
          end
        end

        class CellSelected < State
          attr_reader :cell

          def initialize(cell)
            @cell = cell
          end

          def text
            "cell #{cell} is selected"
          end
        end

        class EmptyCellSelected < CellSelected
          def text
            "#{super}, select number to fill in"
          end
        end

        class FilledCellSelected < CellSelected
          def text
            "#{super}, this cell is already filled"
          end
        end
      end
    end
  end
end
