-module(bower_ct).

%% API
-export([start/0, request/2, request/3, request/4, request/5]).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = application:ensure_all_started(gun).


request(Method, Path) ->
    request(Method, Path, []).


request(Method, Path, Headers) ->
    request(Method, Path, Headers, <<>>).


request(Method, Path, Headers, Body) ->
    request(Method, Path, Headers, Body, #{}).


request(Method0, Path, Headers, Body, ReqOpts) ->
    Connection = connection(),
    Method = method(Method0),
    StreamRef = gun:request(Connection, Method, Path, Headers, Body, ReqOpts),
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

method(Atom) ->
    string:uppercase(atom_to_binary(Atom, utf8)).
