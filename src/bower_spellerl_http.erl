-module(bower_spellerl_http).

-behavior(cowboy_handler).

-ifdef(EUNIT).
-include_lib("eunit/include/eunit.hrl").
-endif.

%% API
-export([init/2]).

%%%===================================================================
%%% API
%%%===================================================================

init(#{method := <<"GET">>} = Req0, Opts) ->
    Term = cowboy_req:binding(term, Req0),
    {StatusCode, Respose} = spell_hanlder(Term),
    Req = bower_util:reply_json(StatusCode, Respose, Req0),
    {ok, Req, Opts};
init(Req0, Opts) ->
    Req = cowboy_req:reply(405, Req0),
    {ok, Req, Opts}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

spell_hanlder(Term) ->
    case spell(Term) of
        {ok, Cardinal} ->
            {200, #{cardinal => Cardinal}};
        {error, Reason} ->
            {404, #{error => Reason}}
    end.

spell(Term) when is_binary(Term) ->
    case cast_int(Term) of
        {ok, Int} ->
            spellerl:spell(Int);
        {error, _Reason} = Error ->
            Error
    end.

cast_int(Binary) when is_binary(Binary) ->
    try
        {ok, binary_to_integer(Binary)}
    catch
        _:_ ->
            {error, not_int}
    end.


-ifdef(EUNIT).

spell_hanlder_test_() ->
    [
     ?_assertEqual({404, #{error => not_int}}, spell_hanlder(<<"foobar">>))
    ].

-endif.
