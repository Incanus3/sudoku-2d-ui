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
          attr_reader :cell, :grid

          def initialize(cell, grid)
            @cell = cell
            @grid = grid
          end

          def text
            additional_text =
              if grid.cell_filled?(cell)
                'this cell is already filled'
              else
                'select number to fill in'
              end

            "you selected cell #{cell}, #{additional_text}"
          end
        end
      end
    end
  end
end
