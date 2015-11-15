%%% @author Yana P. Ribalchenko <yan4ik@gmail.com>
%%% @copyright (C) 2015, Yana P. Ribalchenko
%%% @doc
%%% my tcp_server for connection of telnet
%%% Echo Protocol RFC 862
%%% local server
%%% @end
%%% Created :  7 Oct 2015 by Yana P. Ribalchenko <yan4ik@gmail.com>
%%%-------------------------------------------------------------------
-module(http_mini_tcp_serv).

%% API
-export ([server/0, 
          start_link/0,
          go_recv/1]).

%% TimeOut for connection,in milliseconds.
-define (TIMEOUT, 5000).

-define(SERVER, ?MODULE).

%% Port for connection
-define (PORT, 8080).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    io:format("http_mini_gen_serv gen_server start_link_ECHO (pid ~p)~n", [self()]),
    {ok, spawn_link(fun server/0)}.

    %% spawn (http_mini_tcp_serv, server, []).

%%start_link({local, ?SERVER}, ?MODULE, [], []).


%%--------------------------------------------------------------------
%% @doc start tcp_server
%% @end
%%--------------------------------------------------------------------
-spec server() -> ok.
server () ->
    {ok, LSock} = gen_tcp:listen(
                    ?PORT,
                    [binary, {packet, 0}, {reuseaddr, true}, {active, false}]),
    wait_conn (LSock),
    gen_tcp:close(LSock).

%%%===================================================================
%%% Internal functions
%%%===================================================================
wait_conn(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
%%% этот пид должен передаться супервайзеру
%%% 
    Pid = spawn (http_mini_tcp_serv, go_recv, [Sock] ),
                io:format("Pid=~p~n", [Pid]),
    wait_conn(LSock).


go_recv (Sock) ->
    %%            io:format("SockOpen=~p~n", [Sock]),
    case gen_tcp:recv(Sock, 0) of
        {ok, M} ->
            %%io:format("Sock=~p,~n self()=~p~n Msg=~p~n", [Sock, self(), M]),
            gen_tcp:send (Sock, M),
            go_recv(Sock);
        _ ->
            %%            io:format("SockClose=~p, Bb=~p~n", [Sock, Bb]),
            ok = gen_tcp:close(Sock)
    end.
