module Page.BeerList.Model.Table exposing (init)

import Table


init : Table.State
init =
    Table.initialSort "Year"
