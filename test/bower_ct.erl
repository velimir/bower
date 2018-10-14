-module(bower_ct).

%% API
-export([start/0, request/2]).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = application:ensure_all_started(gun).


request(Method, Path) ->
    Connection = connection(),
    StreamRef = gun:Method(Connection, Path),
    await_response(Connection, StreamRef).

%%%===================================================================
%%% Internal functions
%%%===================================================================
connection() ->
    Port = bower:transport_port(),
    {ok, ConnPid} = gun:open("localhost", Port),
    {ok, _} = gun:await_up(ConnPid),
    ConnPid.

await_response(Connection, StreamRef) ->
    case gun:await(Connection, StreamRef) of
        {response, nofin, Status, _Headers} ->
            {ok, Body} = gun:await_body(Connection, StreamRef),
            {Status, jsx:decode(Body, [return_maps, {labels, atom}])};
        {response, fin, Status, _Headers} ->
            {Status, no_data}
    end.
