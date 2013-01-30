%%%-------------------------------------------------------------------
%%% @author 7er <>
%%% @copyright (C) 2013, 7er
%%% @doc
%%%
%%% @end
%%% Created : 24 Jan 2013 by 7er <>
%%%-------------------------------------------------------------------
-module(scratch).

-export([start/0, init/1]).


start() ->
    spawn(scratch, init, [self()]).

init(From) ->
    loop(From).

loop(From) ->
    receive
        _ ->
            loop(From)
                end.
