-module(bower_http).

-behavior(cowboy_handler).

%% API
-export([init/2]).

%%%===================================================================
%%% API
%%%===================================================================

init(#{method := <<"GET">>} = Req0, Opts) ->
    Req = reply_json(#{hello => world}, Req0),
    {ok, Req, Opts};
init(Req0, Opts) ->
    Req = cowboy_req:reply(405, Req0),
    {ok, Req, Opts}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

reply_json(Object, Req) ->
    reply_json(200, Object, Req).

reply_json(StatusCode, Object, Req) ->
    Headers = #{<<"content-type">> => <<"application/json">>},
    reply_json(StatusCode, Headers, Object, Req).

reply_json(StatusCode, Headers, Object, Req) ->
    Body = jsx:encode(Object),
    cowboy_req:reply(StatusCode, Headers, Body, Req).
