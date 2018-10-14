-module(bower).

%% API
-export([start/0, stop/0, get_env/1, get_env/2]).
-export([transport_options/0, transport_port/0]).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Starts the application and all the ones it depends on.
-spec start() -> {ok, [atom()]}.
start() ->
    {ok, _} = application:ensure_all_started(bower).


%% @doc Stops the application
-spec stop() -> ok | {error, term()}.
stop() ->
    application:stop(?MODULE).


%% @doc get application variable
-spec get_env(atom()) -> term() | undefined.
get_env(Variable) ->
    get_env(Variable, undefined).


%% @doc get application variable
-spec get_env(atom(), term()) -> term().
get_env(Variable, Default) ->
    application:get_env(bower, Variable, Default).


%% @doc return transport options
-spec transport_options() -> proplists:proplist().
transport_options() ->
    get_env(transport).

-spec transport_port() -> pos_integer().
transport_port() ->
    Options = transport_options(),
    {port, Port} = proplists:lookup(port, Options),
    Port.

%%%===================================================================
%%% Internal functions
%%%===================================================================
