-module(bower_log_context_h).

-behavior(cowboy_stream).

%% API
-export([init/3]).
-export([data/4]).
-export([info/3]).
-export([terminate/3]).
-export([early_error/5]).

-record(state, {next :: any()}).

%%%===================================================================
%%% API
%%%===================================================================
-spec init(cowboy_stream:streamid(), cowboy_req:req(), cowboy:opts())
        -> {cowboy_stream:commands(), #state{}}.
init(StreamID, Req, Opts0) ->
    AID = string:uppercase(uuid:uuid_to_string(uuid:get_v4())),
    lager:md([{aid, AID}]),
    Env = maps:get(env, Opts0, #{}),
    Opts = Opts0#{env => Env#{audit_id => AID}},
    {Commands, Next} = cowboy_stream:init(StreamID, Req, Opts),
    {Commands, #state{next = Next}}.


-spec data(cowboy_stream:streamid(), cowboy_stream:fin(), cowboy_req:resp_body(), State)
	-> {cowboy_stream:commands(), State} when State::#state{}.
data(StreamID, IsFin, Data, State0= #state{next = Next0}) ->
    {Commands, Next} = cowboy_stream:data(StreamID, IsFin, Data, Next0),
    {Commands, State0#state{next=Next}}.


-spec info(cowboy_stream:streamid(), any(), State)
	-> {cowboy_stream:commands(), State} when State::#state{}.
info(StreamID, Info, State0 = #state{next = Next0}) ->
    {Commands, Next} = cowboy_stream:info(StreamID, Info, Next0),
    {Commands, State0#state{next=Next}}.

-spec terminate(cowboy_stream:streamid(), cowboy_stream:reason(), #state{}) -> any().
terminate(StreamID, Reason, #state{next = Next}) ->
    cowboy_stream:terminate(StreamID, Reason, Next).


-spec early_error(cowboy_stream:streamid(), cowboy_stream:reason(),
	cowboy_stream:partial_req(), Resp, cowboy:opts()) -> Resp
	when Resp::cowboy_stream:resp_command().
early_error(StreamID, Reason, PartialReq, Resp, Opts) ->
    cowboy_stream:early_error(StreamID, Reason, PartialReq, Resp, Opts).

%%%===================================================================
%%% Internal functions
%%%===================================================================
