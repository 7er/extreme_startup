-module(examinator).
-export([start_link/2, start_link/3, init/3, results/1]).

start_link(Name, Url) ->
    spawn_link(examinator, init, [{Name, Url}, 0, fun query_player/3]).
start_link(Name, Url, QueryFunction) ->
    spawn_link(examinator, init, [{Name, Url}, 0, QueryFunction]).

results(Pid) ->
    Pid ! {self(), results},
    receive
        {Pid, Results} ->
            Results
    end. 

init(State, Qid, QueryFunction) ->
    self() ! ask_new_question,
    loop(State, Qid, [], QueryFunction).

sleep(Millis) ->
    receive 
            after Millis ->
            ok
    end.

loop({Name, Url}, Qid, Results, QueryFunction) ->
    receive
        ask_new_question ->
            {Question, CorrectAnswer} = next_question(),
            SelfPid = self(),
            spawn(fun () -> 
                    Response = QueryFunction(Url, Question, Qid),
                    io:format("Got response ~n~p~n", [Response]),
                    Grade = grade_response(Response, CorrectAnswer),
                    ok = leaderboard:update(Name, Grade),
                    SelfPid ! {question_result, Qid, Grade, Response}
                end),
            loop({Name, Url}, Qid, Results, QueryFunction);
        {question_result, Qid, Grade, Response} ->
            ask_new_question_later(),
            loop({Name, Url}, Qid+1, [{Qid, Grade, Response}|Results], QueryFunction);
        {From, results} ->
            From ! {self(), Results},
            loop({Name, Url}, Qid, Results, QueryFunction)
    end.

ask_new_question_later() ->
    SelfPid = self(),
    spawn(fun () ->
            sleep(3000),
            SelfPid ! ask_new_question
        end).

query_player(Url, Question, Qid) ->
    {ok, RequestId} = httpc:request(get, {generate_question_url(Url, Question, Qid), []}, [], [{sync, false}]),
    receive
        {http, {RequestId, Response}} ->
            Response
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
