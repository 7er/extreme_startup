-module(helloworld).
-export([config_data/0]).
-export([helloworld/2]).

config_data()->
    {testtool,
     [{web_data,{"TestTool","/testtool/helloworld/helloworld"}},
      {alias,{erl_alias,"/testtool",[helloworld]}}]}.

helloworld(_Env,_Input)->
    io:format("Env: ~p~nInput: ~p~n", [_Env, _Input]),
    [header(),html_header(),leaderboard_body(),html_end()].

header() ->
    header("text/html").

header(MimeType) ->
    "Content-type: " ++ MimeType ++ "\r\n\r\n".

html_header() ->    
    "<HTML>
               <HEAD>
        <TITLE>Hello world Example </TITLE>
        </HEAD>\n".

helloworld_body()->
    "<BODY>Hello World</BODY>".


leaderboard_body() ->
    %io:format("leaderboard:~p~n", [leaderboard:list()]),
    %"<BODY>Hello World</BODY>".
    {ok, List} = leaderboard:list(),
    ["<ul>\n",
	create_html_list(List),
	"</ul>\n"].


html_end()->
    "</HTML>".


create_html_list(List) ->
	lists:flatmap(fun format_tupple/1, List).
	
format_tupple({First,Last}) ->
	io_lib:format("<li>NAME:~p Score:~p</li>~n", [First,Last]).
