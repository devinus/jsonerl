-define(record_to_struct(RecordName, Record),
  begin
  % getting the record field names
  Fields = record_info(fields, RecordName),
  %
  RecordData = lists:map(
    %% convention record's *undefined* value is represented as json's *null*
    fun(undefined) -> null;
       (E) -> E
    end,
    %% we are turning the record into list chopping its head (record name) off
    tl(tuple_to_list(Record))
  ),
  % we are zipping record's field names and corresponding values together
  % then we turn it into tuple resulting in *struct* - erlang's equivalent of json's *object*
  list_to_tuple(lists:zip(Fields,RecordData))
  end
).

-define(struct_to_record(RecordName, Struct),
  begin
    % getting the record field names in the order the tuple representing the record instance has its values
    Fields = record_info(fields, RecordName),
    % create quickly accessible maping of struct values by its keys turned to atoms, as it is in records.
    ValuesByFieldsDict = lists:foldl(
      fun({K, V}, Dict) ->
        dict:store(utils:to_ex_a(K), V, Dict)
      end,
      dict:new(),
      tuple_to_list(Struct)
    ),
    % construct the tuple being the proper record from the struct
    list_to_tuple(
      %% first element in the tuple is record name
      [RecordName] ++
      lists:map(
        %% convention: json's *null* represents record's *undefined* value
        fun(Field) ->
          case dict:find(Field, ValuesByFieldsDict) of
            {ok, Value} -> Value;
            error -> undefined
          end  
        end,
        Fields
      )
    )
  end
).

-define(record_to_json(RecordName, Record),
  begin
    % serialize erlang struct into json string
    Struct = ?record_to_struct(RecordName, Record),
    jsonerl:encode(Struct)
  end
).

-define(json_to_record(RecordName, Json),
   begin
    % decode json text to erlang struct
    Struct = jsonerl:decode(Json),
    ?struct_to_record(RecordName, Struct)
   end
).
