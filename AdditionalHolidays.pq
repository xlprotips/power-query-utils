// Additional Observed Holidays
let
  Query1 = Table.FromRecords({  
    [Date = null, Name = null]
  }),
  #"Changed Type" = Table.TransformColumnTypes(Query1,{{"Date", type date}})
in
  #"Changed Type"
