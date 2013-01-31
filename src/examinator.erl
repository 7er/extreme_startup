-module(examinator).
-export([start_link/2, init/2, results/1]).

start_link(Name, Url) ->
    spawn_link(examinator, init, [{Name, Url}, 0]).

results(Pid) ->
    Pid ! {self(), results},
    receive
        {Pid, Results} ->
            Results
    end. 

init(State, Qid) ->
    loop(State, Qid, []).


sleep(Millis) ->
    receive 
    after Millis ->
            ok
    end.

loop({Name, Url}, Qid, Results) ->
    {Question, CorrectAnswer} = next_question(),
    {ok, RequestId} = httpc:request(get, {generate_question_url(Url, Question, Qid), []}, [], [{sync, false}]),
    receive
        {http, {RequestId, Response}} ->
            io:format("Got response ~n~p~n", [Response]),
            Grade = grade_response(Response, CorrectAnswer),
            ok = leaderboard:update(Name, Grade),
            sleep(3000),
            loop({Name, Url}, Qid+1, [{Qid, Grade, Response}|Results]);
        {From, results} ->
            From ! {self(), Results},
            loop({Name, Url}, Qid, Results)
    end.

next_question() ->
    {"Hvor lang er bananen?", "veldig lang"}.

generate_question_url(Base, Question, Id) ->
    lists:flatten(io_lib:format("~s?q=~s&qid=~p", [Base, edoc_lib:escape_uri(Question), Id])).

grade_response({{_, 200, _}, _, BinaryAnswer}, CorrectAnswer) ->
    Answer = binary_to_list(BinaryAnswer),    
    grade_answer(CorrectAnswer, Answer);
grade_response(_, _) ->
    -1.

grade_answer(Answer, Answer) ->
    1;
grade_answer(_, _) ->
    0.
