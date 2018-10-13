-module(bower_http_log_handler).

%% API
-export([execute/1]).

%%%===================================================================
%%% API
%%%===================================================================

-spec execute(cowboy_metrics_h:metrics()) -> ok.
execute(#{early_error_time := _ErrorTime, partial_req := Req} = Metrics) ->
    lager:error("~s \"~s ~s ~s\" ~p ~p -- performed in ~b ms with error ~p",
                [peer(Req), method(Req), path(Req), version(Req),
                 resp_status(Metrics), resp_body_length(Metrics), performed_in(Metrics),
                 reason(Metrics)]);
execute(#{req := Req} = Metrics) ->
    lager:info("~s \"~s ~s ~s\" ~p ~p -- performed in ~b ms",
               [peer(Req), method(Req), path(Req), version(Req),
                resp_status(Metrics), resp_body_length(Metrics), performed_in(Metrics)]).

%%%===================================================================
%%% Internal functions
%%%===================================================================
peer(#{peer := {IPAddress, _Port}}) -> inet:ntoa(IPAddress).

method(#{method := Method}) -> Method.

path(#{path := Path}) -> Path.

version(#{version := Version}) -> Version.

resp_status(#{resp_status := Code}) -> Code.

resp_body_length(#{resp_body_length := Length}) -> Length.

reason(#{reason := Reason}) -> Reason.

performed_in(#{req_start := Start, early_error_time := End}) ->
    ms_diff(End - Start);
performed_in(#{req_start := Start, req_end := End}) ->
    ms_diff(End - Start).

ms_diff(NativeTime) ->
    erlang:convert_time_unit(NativeTime, native, millisecond).
