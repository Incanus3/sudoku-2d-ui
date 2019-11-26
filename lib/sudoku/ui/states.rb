module Sudoku
  class UI
    module States
      class State
      end

      class WaitingForCellSelection < State
      end

      class CellSelected < State
        attr_reader :cell

        def initialize(cell)
          @cell = cell
        end
      end
    end
  end
end
