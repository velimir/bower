%%%-------------------------------------------------------------------
%% @doc bower public API
%% @end
%%%-------------------------------------------------------------------

-module(bower_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([{'_', [{"/", bower_http, []}]}]),
    Env = #{
            env              => #{dispatch => Dispatch},
            stream_handlers  => [bower_log_context_h, cowboy_metrics_h, cowboy_stream_h],
            metrics_callback => fun bower_http_log_handler:execute/1,
            middlewares      => [bower_context, cowboy_router, cowboy_handler]
           },
    {ok, _} = cowboy:start_clear(?MODULE, [{port, 8080}], Env),
    bower_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
