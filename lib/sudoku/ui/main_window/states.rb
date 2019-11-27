module Sudoku
  module UI
    class MainWindow
      module States
        class State
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
            "you selected cell #{cell}"
          end
        end
      end
    end
  end
end
