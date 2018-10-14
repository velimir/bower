-module(bower_http).

-behavior(cowboy_handler).

%% API
-export([init/2]).

%%%===================================================================
%%% API
%%%===================================================================

init(#{method := <<"GET">>} = Req0, Opts) ->
    Req = bower_util:reply_json(#{hello => world}, Req0),
    {ok, Req, Opts};
init(Req0, Opts) ->
    Req = cowboy_req:reply(405, Req0),
    {ok, Req, Opts}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
