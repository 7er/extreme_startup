-module(server_tests).
-include_lib("eunit/include/eunit.hrl").
     
    

parse_test() ->
    ?assertEqual(
       {"GET", "/index.html", "HTTP/1.1"},
       server:parse_request_line("GET /index.html HTTP/1.1")),
    ?assertEqual(
       [],
       server:parse_query_string("/index.html")),
    ?assertEqual(
       [{"q", "flamme"}],
       server:parse_query_string("/index.html?q=flamme")).
    

    

