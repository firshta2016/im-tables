NestedTableModel = require '../../models/nested-table'
SubTable = require './subtable' # FIXME!
Cell = require './cell'

# :: (service, opts) -> (cell) -> CellView
# where
# service = Service
# opts = {
#   canUseFormatter :: fn -> bool,
#   expandedSubtables :: Collection,
#   popoverFactory :: PopoverFactory,
#   selectedObjects :: SelectedObjects,
#   tableState :: TableModel
# }
# CellView = Cell | SubTable
module.exports = (service, opts) ->
  base = service.root.replace /\/service\/?$/, ""
  cellify = (cell) ->
    if cell instanceof NestedTableModel
      return new SubTable
        model: cell
        cellify: cellify
        canUseFormatter: opts.canUseFormatter
        expandedSubtables: ops.expandedSubtables
    else
      return new Cell
        model: cell
        service: service
        popovers: opts.popoverFactory
        selectedObjects: opts.selectedObjects
        tableState: opts.tableState
