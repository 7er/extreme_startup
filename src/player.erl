-module(player).

-export([ask_question/3]).


ask_question(QuestionId, BaseUrl, Question) ->
    Url = lists:flatten(io_lib:format("~s?q=~s&qid=~s", [BaseUrl, edoc_lib:escape_uri(Question), QuestionId])),
    process_result(httpc:request(Url)).

process_result({ok, {{_, 200, _}, _Headers, Body}}) ->
    {ok, Body};
process_result({error, _}=Error) ->
    Error;
process_result(UnknownError) ->
    {error, UnknownError}.
