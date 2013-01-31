-module(user_default).

-compile(export_all).

reload(M) ->
    code:purge(M),
    code:soft_purge(M),
    {module, M} = code:load_file(M),
    {ok, M}.

reload_all() ->
    reload_all([extreme_app, extreme_sup, leaderboard, player_registry,  examinator_sup]).

reload_all([M|Tail]) ->
    reload(M),
    reload_all(Tail);
reload_all([]) ->
    ok.
