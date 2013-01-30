%%%-------------------------------------------------------------------
%%% @author 7er <>
%%% @copyright (C) 2013, 7er
%%% @doc
%%%
%%% @end
%%% Created : 23 Jan 2013 by 7er <>
%%%-------------------------------------------------------------------
-module(was_examinator).

-export([start/2, init/1]).


start(Name, Url) ->
    spawn_link(examinator, init, [{Name, Url}]).

init(State) ->
    loop(State, 0).

gen_uid(Name, Count) ->
    lists:flatten(io_lib:format("~s-~p", [Name, Count])).

sleep(Msecs) ->
    receive
    after Msecs -> 
            true
    end.



loop({Name, Url}, Count) ->
    Question = "Hvilken farge har bananen?",
    case player:ask_question(gen_uid(Name, Count), Url, Question) of
        {ok, Answer} ->           
            io:format("Player ~p answered ~p~n", [Name, Answer]);
        {error, Reason} ->
            io:format("Player ~p failure, reason: ~p~n", [Name, Reason])
    end,
    % grade ready
    sleep(2000),
    loop({Name, Url}, Count + 1).

