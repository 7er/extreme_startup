
-module(extreme_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_in_shell_for_testing/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_in_shell_for_testing() ->
    {ok, Pid} = start_link(),
    unlink(Pid).


%% ===================================================================
%% Supervisor callbacks
%% ===================================================================



init([]) ->
    PlayerRegistry = {tag1, 
                      {player_registry, start_link, []},
                      permanent, 
                      10000,
                      worker,
                      [player_registry]},
    LeaderBoard = {tag2, 
            {leaderboard, start_link, []},
            permanent, 
            10000,
            worker,
            [leaderboard]},
    ExaminatorSup = {tag3, 
                     {examinator_sup, start_link, []},
                     permanent, 2000, supervisor, 
                     [examinator_sup]},
    {ok, {{one_for_one, 3, 10}, 
          [
           PlayerRegistry,
           LeaderBoard
          ]} }.

