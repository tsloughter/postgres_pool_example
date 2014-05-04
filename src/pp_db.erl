%%%-------------------------------------------------------------------
%%% @author Tristan Sloughter <tristan@heroku.com>
%%% @copyright (C) 2014, Tristan Sloughter
%%% @doc
%%%
%%% @end
%%% Created : 02 May 2014 by Tristan Sloughter <tristan@heroku.com>
%%%-------------------------------------------------------------------
-module(pp_db).

-export([open/1
        ,close/1
        ,get_connection/1
        ,return_connection/2
        ,query/1]).

-spec get_connection(atom()) -> {pgsql_connection, pid()} | {error, timeout}.
get_connection(Pool) ->    
    case episcina:get_connection(Pool) of
        {ok, Pid} ->
            {pgsql_connection, Pid};
        {error, timeout} ->
            {error, timeout}
    end.

-spec return_connection(atom(), {pgsql_connection, pid()}) -> ok.
return_connection(Pool, {pgsql_connection, Pid}) ->
    episcina:return_connection(Pool, Pid).

-spec open(list()) -> {ok, pid()}.
open(DBArgs) ->    
    {pgsql_connection, Pid} = pgsql_connection:open(DBArgs),
    {ok, Pid}.

-spec close(pid()) -> ok.
close(Pid) ->
    pgsql_connection:close({pgsql_connection, Pid}).

-spec query(string()) -> tuple().
query(Query) ->
    C = get_connection(primary),
    try
        pgsql_connection:simple_query(Query, [], infinity, C)    
    after
        return_connection(primary, C)
    end.
