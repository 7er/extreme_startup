-module (server).

-export([start/1, init/1, listen/1]).


-export([parse_query_string/1, parse_request_line/1]).


listen(Port) ->
    {ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 0},
                                         {reuseaddr, true},
                                         {active, true}]),
    Listen.


start(Listen) ->
    spawn(server, init, [Listen]).

init(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(server, init, [Listen]),
    inet:setopts(Socket, [{packet,0},binary, {nodelay,true},{active, true}]),
    loop_request(Socket, []).

loop_request(Socket, L) ->
    receive
        {tcp, Socket, Bin} ->
            L1 = L ++ binary_to_list(Bin),
            %% split checks if the header is complete
            case split(L1, []) of
                more ->
                    %% the header is incomplete we need more data
                    loop_request(Socket, L1);
                {RequestAndHeaders, Body} ->
                    %% header is complete
                    [Request|Headers] = string:tokens(RequestAndHeaders, "\r\n"),
                    io:format("***Request***~n~s~n", [Request]),
                    io:format("***Headers***~n~s~n", [string:join(Headers, "\n")]),
                    io:format("***Rest****~n~p~n", [Body]),
                    got_request_from_client(Socket, Request, Headers, Body),
                    ok = gen_tcp:close(Socket)
            end;
        {tcp_closed, Socket} ->
            void
    end.

split("\r\n\r\n" ++ T, L) -> {lists:reverse(L), T};
split([H|T], L) -> split(T, [H|L]);
split([], _) -> more.


parse_query_string(PathInfo) ->
    case string:tokens(PathInfo, "?") of 
        [_, QueryString] ->
            query_to_proplist(QueryString);
        [_] ->
            ""
    end.

query_to_proplist(QueryString) ->
    queries_to_proplist(string:tokens(QueryString, "&")).

queries_to_proplist([Head|Tail]) ->
    [Key, Value] = string:tokens(Head, "="),
    [{Key, Value}|queries_to_proplist(Tail)];
queries_to_proplist([]) ->
    [].



parse_request_line(Line) ->
    [Method, PathInfo, Version] = string:tokens(Line, " "),
    {Method, PathInfo, Version}.



got_request_from_client(Socket, Request, _Headers, _Body) ->
    gen_tcp:send(Socket, [response(handle_request(Request))]).

handle_request(Request) ->
    {_, PathInfo, _} = parse_request_line(Request),
    QueryProplist = parse_query_string(PathInfo),
    handle_query(QueryProplist).

handle_query(QueryProplist) ->
    case proplists:get_value("q", QueryProplist) of
        "fresk" ->
            "fisken";
        "snusk" ->
            "svesken"
    end.



response(Str) ->
    ["HTTP/1.0 200 OK\r\n",
     "Connection: close\r\n\r\n",
     Str].
