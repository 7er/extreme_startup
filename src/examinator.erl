-module(examinator).
-export([start/2, init/2, results/1]).

start(Name, Url) ->
    spawn(examinator, init, [{Name, Url}, 0]).

results(Pid) ->
    Pid ! {self(), results},
    receive
        {Pid, Results} ->
            Results
    end.

init(State, Qid) ->
    loop(State, Qid, []).

loop({Name, Url}, Qid, Results) ->
    {Question, CorrectAnswer} = next_question(),
    {ok, RequestId} = httpc:request(get, {generate_question_url(Url, Question, Qid), []}, [], [{sync, false}]),
    receive
        {http, {RequestId, Response}} ->
            Answer = check_response(Response),
            Grade = check_answer(CorrectAnswer, Answer),  		
            leaderboard:update(Name, Grade),
            loop({Name, Url}, Qid+1, [{Qid, Grade, Response}|Results]);
        {From, results} ->
            From ! {self(), Results},
            loop({Name, Url}, Qid, Results)
    end.

next_question() ->
    {"Hvor lang er bananen?", "veldig lang"}.

generate_question_url(Base, Question, Id) ->
    lists:flatten(io_lib:format("~s?q=~s&qid=~s", [Base, Question, Id])).

check_response({ok, {{_, 200, _}, _, Answer}}) ->
    Answer.

check_answer(Answer, Answer) ->
    1;
check_answer(_, _) ->
    0.
