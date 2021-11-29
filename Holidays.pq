// Holiday Name
let FunctionDefinition = (InputDate as date) as nullable text =>
  let
    Dow = Date.DayOfWeek(InputDate, Day.Sunday),
    IsMonday = Dow = 1,
    IsThursday = Dow = 4,
    IsFriday = Dow = 5,
    FirstWeekdayOfMonth = Date.DayOfWeek(Date.StartOfMonth(InputDate), Day.Sunday),
    Delta = if Dow >= FirstWeekdayOfMonth then Dow - FirstWeekdayOfMonth else 7 + Dow - FirstWeekdayOfMonth,
    FirstSameDayOfMonth = Date.AddDays(#date(Date.Year(InputDate), Date.Month(InputDate), 1), Delta),
    NthDayOfMonth = Number.IntegerDivide(Duration.Days(InputDate - FirstSameDayOfMonth), 7) + 1,
    Month = Date.Month(InputDate),
    Day = Date.Day(InputDate)
  in
    if Month = 1 and Day = 1 then "New Year's"
    else if Month = 1 and IsMonday and NthDayOfMonth = 3 then "Martin Luther King Day"
    else if Month = 2 and IsMonday and NthDayOfMonth = 3 then "President's Day"
    else if Month = 5 and IsMonday and Date.Month(Date.AddDays(InputDate, 7)) <> Month then "Memorial Day"
    else if Month = 7 and Day = 4 then "4th of July"
    else if Month = 9 and IsMonday and NthDayOfMonth = 1 then "Labor Day"
    else if Month = 11 and IsThursday and NthDayOfMonth = 4 then "Thanksgiving"
    else if Month = 11 and IsFriday and @FunctionDefinition(Date.AddDays(InputDate, -1)) = "Thanksgiving" then "Day After Thanksgiving"
    else if Month = 12 and Day = 24 then "Christmas Eve"
    else if Month = 12 and Day = 25 then "Christmas"
    else if Month = 12 and Day = 31 then "New Year's Eve"
    else null
in FunctionDefinition
