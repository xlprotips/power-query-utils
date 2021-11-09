let
  CalendarStart = ForecastStart,
  CalendarEnd = Date.EndOfMonth(Date.AddMonths(ForecastStart, ForecastNumPeriods - 1)),
  Periods = List.Generate(
    () => CalendarStart,
    each _ <= CalendarEnd,
    each Date.AddDays(_, 1)
  ),
  #"Periods to Table" = Table.FromList(Periods, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
  #"Rename Primary Col" = Table.RenameColumns(#"Periods to Table", {"Column1", "Date"}),
  #"Set Period Type" = Table.TransformColumnTypes(#"Rename Primary Col",{{"Date", type date}}),
  #"Add Month Name" = Table.AddColumn(#"Set Period Type", "Month Name", each Date.ToText([Date], "MMMM")),
  #"Add Year" = Table.AddColumn(#"Add Month Name", "Year", each Date.ToText([Date], "yyyy")),
  #"Add Month Num" = Table.AddColumn(#"Add Year", "Month (Int)", each Date.Month([Date])),
  #"Add Quarter" = Table.AddColumn(#"Add Month Num", "Quarter", each "Q" & Number.ToText(Number.IntegerDivide([#"Month (Int)"] - 1, 3) + 1)),
  #"Add EoM" = Table.AddColumn(#"Add Quarter", "Month End", each Date.EndOfMonth([Date])),
  #"Add Yr/Mo" = Table.AddColumn(#"Add EoM", "Year/Month", each Number.ToText(Date.Year([Date])) & "-" & Text.PadStart(Number.ToText(Date.Month([Date])), 2, "0")),
  #"Add Yr/Qtr" = Table.AddColumn(#"Add Yr/Mo", "Year/Quarter", each Number.ToText(Date.Year([Date])) & "-" & [Quarter]),
  #"Add Standard Holiday Name" = Table.AddColumn(#"Add Yr/Qtr", "Standard.Holiday Name", each #"Holiday Name"([Date])),
  #"Merge Custom Holidays" = Table.NestedJoin(#"Add Standard Holiday Name", {"Date"}, #"Additional Observed Holidays", {"Date"}, "Additional Observed Holidays", JoinKind.LeftOuter),
  #"Expand Custom Holidays" = Table.ExpandTableColumn(#"Merge Custom Holidays", "Additional Observed Holidays", {"Name"}, {"Custom Holiday.Name"}),
  #"Merge Standard Holidays Observed" = Table.NestedJoin(#"Expand Custom Holidays", {"Standard.Holiday Name"}, #"Known Holidays", {"Holiday"}, "Known Holidays", JoinKind.LeftOuter),
  #"Expand Standard Holidays Observed" = Table.ExpandTableColumn(#"Merge Standard Holidays Observed", "Known Holidays", {"Observed?"}, {"Known Holidays.Observed?"}),
  #"Add Num Holidays" = Table.AddColumn(#"Expand Standard Holidays Observed", "Number of Holidays", each
    if [Custom Holiday.Name] <> null or ([Standard.Holiday Name] <> null and [#"Known Holidays.Observed?"] = "Yes") then 1 else 0
  ),
  #"Add Holiday Name" = Table.AddColumn(#"Add Num Holidays", "Holiday Name", each if [Standard.Holiday Name] = null then [Custom Holiday.Name] else [Standard.Holiday Name]),
  #"Remove Old Holiday Columns" = Table.RemoveColumns(#"Add Holiday Name",{"Standard.Holiday Name", "Custom Holiday.Name", "Known Holidays.Observed?"}),
  #"Add Num Weekdays" = Table.AddColumn(#"Remove Old Holiday Columns", "Number of Weekdays", each
    let dow = Date.DayOfWeek([Date], Day.Sunday)
    in if dow = 0 or dow = 6 then 0 else 1
  ),
  #"Add Num Bus Days" = Table.AddColumn(#"Add Num Weekdays", "Number of Business Days", each
    if [Number of Holidays] = 0 and [Number of Weekdays] = 1 then 1
    else 0
  ),
  #"Add Is Month End" = Table.AddColumn(#"Add Num Bus Days", "Is Month End?", each
    if [Date] = Date.EndOfMonth([Date]) then true
    else false
  ),
  #"Changed Type" = Table.TransformColumnTypes(#"Add Is Month End",{
    {"Month End", type date},
    {"Month (Int)", Int64.Type},
    {"Year", Int64.Type},
    {"Number of Holidays", Int64.Type},
    {"Number of Business Days", Int64.Type},
    {"Number of Weekdays", Int64.Type},
    {"Is Month End?", type logical}
  })
in
  #"Changed Type"
