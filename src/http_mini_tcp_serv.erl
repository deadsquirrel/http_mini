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
          go_recv/1,
          request_port/0
%% ,
%%           request_content/0
         ]).

%% TimeOut for connection,in milliseconds.
-define (TIMEOUT, 5000).

-define(SERVER, ?MODULE).

%% Port for connection
%%-define (PORT, 7777).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
%%    io:format("http_mini_gen_serv start_link_ECHO (pid ~p)~n", [self()]),
    {ok, spawn_link(fun server/0)}.

    %% spawn (http_mini_tcp_serv, server, []).

%%start_link({local, ?SERVER}, ?MODULE, [], []).


%%--------------------------------------------------------------------
%% @doc start tcp_server
%% @end
%%--------------------------------------------------------------------
-spec server() -> ok.
server () ->
    case request_port() of
        {ok, Port} ->
            case gen_tcp:listen(
                   Port,
                   [binary, {packet, 0}, {reuseaddr, true}, {active, false}])
            of
                {ok, LSock} ->  wait_conn (LSock),
                                gen_tcp:close(LSock);
                {error, Reason} -> Reason
            end;
        _ ->
            errorport
    end.



%%%===================================================================
%%% Internal functions
%%%===================================================================
wait_conn(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    Pid = spawn (http_mini_tcp_serv, go_recv, [Sock] ),
                io:format("Wait Pid=~p~n", [Pid]),
    wait_conn(LSock).


go_recv (Sock) ->
    case gen_tcp:recv(Sock, 0) of
        
        {ok, Zapros} ->
            Stroka = binary_to_list(Zapros),
            io:format("Stroka = ~p~n", [Stroka]),
            io:format("Zapros = ~p~n", [Zapros]),
            [H|T] = string:tokens(Stroka, " "),
            io:format("Head = ~p~n", [H]),
            io:format("Tail = ~p~n", [T]),
            if H == "GET" ->
                    
                    oK;
                    %%parsing:pars(T, 1);
               true -> xpenb
            end,
            
            
            
            Outfile= gs_content:get_content(),
            gen_tcp:send (Sock, Outfile),
            io:format("OutFile=~p~n", [Outfile]),
            go_recv(Sock)
                
    end.





%%         <<"asdf">>
        %% <<"GET /about.html HTTP/1.0\r\nHost: localhost:8888\r\n\r\n">>
%%        } ->
            %% по идее сюда надо вставить содержимое файл передаваемый


        %% _Oth ->
        %%     io:format("Ya vizhu: ~p~n", [_Oth]),
        %%     gen_tcp:send (Sock, <<"HTTP/1.x 434 Requested host unavailable\r\nServer: Yankizaur/0.1.1\r\n\r\n<html><head></head><body>host not available</body></html>\r\n">>),
        %%     gen_tcp:close(Sock)

            %% _ ->
            %%     ok = gen_tcp:close(Sock)


%%%===================================================================
%%% запрашиваем порт
%%%===================================================================

request_port() ->
    _Port_config = gs_config:get_port().

%%%===================================================================
%%% запрашиваем чего б отдать пользователю
%%% наверное надо проверить на ошибки
%%%==== ===============================================================
%% request_content() ->
%%     gs_content:get_cont().

    %% Pid = whereis(gs_content),
    %% receive
    %%     {Pid, Scont} -> Scont
    %% after 2000 ->
    %%         timeout
    %% end.
