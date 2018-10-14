-module(bower_util).

%% API
-export([reply_json/2, reply_json/3, reply_json/4]).

%%%===================================================================
%%% API
%%%===================================================================

reply_json(Object, Req) ->
    reply_json(200, Object, Req).

reply_json(StatusCode, Object, Req) ->
    Headers = #{<<"content-type">> => <<"application/json">>},
    reply_json(StatusCode, Headers, Object, Req).

reply_json(StatusCode, Headers, Object, Req) ->
    Body = jsx:encode(Object),
    cowboy_req:reply(StatusCode, Headers, Body, Req).

%%%===================================================================
%%% Internal functions
%%%===================================================================
