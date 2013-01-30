-module(scenario_tests).
-include_lib("eunit/include/eunit.hrl").
     
register_and_query() ->
    application:start(extreme).
