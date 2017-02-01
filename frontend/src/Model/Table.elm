module Model.Table exposing (init)

import Table


init : Table.State
init =
    Table.initialSort "Brewery"
