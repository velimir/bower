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
    Dispatch = cowboy_router:compile(routes()),
    Env = #{
            env              => #{dispatch => Dispatch},
            stream_handlers  => [bower_log_context_h, cowboy_metrics_h, cowboy_stream_h],
            metrics_callback => fun bower_http_log_handler:execute/1,
            middlewares      => [bower_context, cowboy_router, cowboy_handler]
           },
    TransportOpts = bower:transport_options(),
    {ok, _} = cowboy:start_clear(?MODULE, TransportOpts, Env),
    bower_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok = cowboy:stop_listener(?MODULE).

%%====================================================================
%% Internal functions
%%====================================================================

routes() ->
    HostMatch = '_',
    Paths =
        [{"/spellerl/v1/spell/:term", bower_spellerl_http, []},
         {"/", bower_http, []}],
    [{HostMatch, Paths}].
