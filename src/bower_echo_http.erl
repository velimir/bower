-module(bower_echo_http).

-behavior(cowboy_handler).

%% API
-export([init/2]).

%%%===================================================================
%%% API
%%%===================================================================

init(#{method := <<"POST">>} = Req0, Opts) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0),
    Req1 = bower_util:reply_json(#{request => Body}, Req),
    {ok, Req1, Opts};
init(Req0, Opts) ->
    Req = cowboy_req:reply(405, Req0),
    {ok, Req, Opts}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
