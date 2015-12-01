%%% @author Yana P. Ribalchenko <yan4ik@gmail.com>
%%% @copyright (C) 2015, Yana P. Ribalchenko
%%% @doc
%%% my tcp_server for connection of telnet
%%% Echo Protocol RFC 862
%%% local server
%%% @end
%%% Created :  7 Oct 2015 by Yana P. Ribalchenko <yan4ik@gmail.com>
%%%-------------------------------------------------------------------
-module(http_mini_tcp_serv2).

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
                io:format("Wait2 Pid=~p~n", [Pid]),
    wait_conn(LSock).


go_recv (Sock) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, Zapros} ->
%% not sure --------------
%%            receive_data(Sock, []),
%% end of not sure --------
            Stroka = binary_to_list(Zapros),
            io:format("Stroka2 = ~p~n", [Stroka]),
            io:format("Zapros2 = ~p~n", [Zapros]),
            [H|_T] = string:tokens(Stroka, " "),
%%            io:format("Head = ~p~n", [H]),
%%            io:format("Tail = ~p~n", [T]),
            Proplist = 
                if H == "GET" ->
%% может запустить тут процесс
                        parsing(Stroka);
                        %% Pid = spawn (http_mini_tcp_serv, parsing, [Stroka] ),
                        %% io:format("Parsing Pid=~p~n", [Pid]);
                   true -> xpenb
                end,
            
            %% проверку по проплисту
            %% если результат ожидаемый, отдаем файл
            
            Outfile = gs_content2:get_content(),
%% ----------------------------------------------------------------------------
%%  из *app.src получаем следующие параметры параметры для сравнения
%% ----------------------------------------------------------------------------
            %% "localhost"
            %% {ok, Adress} = application:get_env (http_mini, host), 
            %% io:format("Adress =~p~n ", [Adress]), 
%% попробовать сделать выбор из списка адресов            
 {ok, Adress} = application:get_env (http_mini, host2), 
             io:format("Adress 2=~p~n ", [Adress]), 

            {ok, Port} = application:get_env (http_mini, port2), 
            io:format("Port 2= ~p~n", [Port]), 
            {ok, File} = application:get_env (http_mini, file2),
            io:format("File 2= ~p~n", [File]), 
%%            {ok, Reply} = application:get_env (http_mini, fileout2),
            io:format("ACHTUNG! Reply 2= ~p~n", [Outfile]), 
%% ----------------------------------------------------------------------------
%%  парсим proplist
%% ----------------------------------------------------------------------------

            %%  "/about.html"
            Get = proplists:get_value(get, Proplist), 
            io:format("Get  = ~p~n", [Get]), 
            %%  "localhost:8888"
            [Host] =  proplists:get_value(host, Proplist), 
            [Host2|[P]] = string:tokens(Host, ":"),
            io:format("Host2 = ~p~n", [Host2]), 
            Port2= list_to_integer(P),
            io:format("Port2 = ~p~n", [Port2]), 
            Adress,
            File,
            Get,
            Host2,
            Port2,
%% ----------------------------------------------------------------------------
%% сравниваем
%% ----------------------------------------------------------------------------
            if
                Port == Port2 ->
                    if 
                        Host2 == Adress ->
                            if
                                Get == File
                                ->
                                    %% io:format("OutFile=~p~n", [Outfile]),
                                    gen_tcp:send (Sock, responce(twohundred, Outfile)),
                                    gen_tcp:close(Sock);
                                %% или соединить в один Reply
                                %% тут не файл отдаем, а сформированный ответ вместе с файлом!!!!! 
                                true -> 
                                    gen_tcp:send (Sock,responce(fortyfour, Outfile)), 
                                    gen_tcp:close(Sock)
                            end;
                        true  ->
                            gen_tcp:send (Sock,responce(thirtyfour, Outfile)),
                            gen_tcp:close(Sock)
                    end,
                    go_recv(Sock)
            end;        
        _Oth ->
%% здесь Reply еще не известна, надо объявить где-то еще, или написать вручную. пока что
%%            gen_tcp:send (Sock, Reply),
            gen_tcp:send (Sock, <<"HTTP/1.x 434 Requested host unavailable\r\nServer: Yankizaur/0.1.1\r\n\r\n<html><head></head><body>host not available</body></html>\r\n">>),
            gen_tcp:close(Sock)
    end.

responce(fortyfour, _Resp) ->
    <<"HTTP/1.x 404 Not found\r\nServer: localhost\r\n\r\n<html><head></head><body>404 File not found</body></html>\r\n">>; 
responce(thirtyfour, _Resp) ->
<<"HTTP/1.x 434 Requested host unavailable\r\nServer: Yankizaur/0.1.1\r\n\r\n<html><head></head><body>host not available</body></html>\r\n">>;
responce(twohundred, Reply) ->
%%  в оригинальном модуле он есть. потестировать без него либо добавить
    create_reply_header(Reply)++Reply;
responce(_, _Resp) ->
    ups.

create_reply_header (Outfile) ->
    [<<"HTTP/1.0 200 OK">>, 
     <<"\r\n">>, 
     <<"Server: ">>,    list_to_binary(serverName()),<<"\r\n">>,
     <<"Data: ">>,     list_to_binary(httpd_util:rfc1123_date()),
     <<"\r\n">>, 
     <<"Content-Type: text/html">>, <<"\r\n">>, 
     <<"Content-Length: ">>, 
     list_to_binary(integer_to_list(byte_size(Outfile))),
     <<"\r\n\r\n">>].

 serverName () ->
     {ok, Name} = application:get_env (http_mini, servername2),
     Name.



%%%===================================================================
%%% парсим полученные строки 
%%%===================================================================
parsing (List) -> 
    List2 = string:tokens(List, "\r\n"),
    Asdf = pars1(List2, []),
    io:format("asdf = ~p~n", [Asdf]),
    Asdf.

pars1 ([], Acc) -> lists:reverse(Acc);
pars1 ([H|T], Acc) ->
    Str= pars_stn (string:tokens(H, " ")),
    Acc2=[Str|Acc],
    pars1(T, Acc2).

pars_stn ([H|T]) ->
    if 
        H == "GET" -> 
            [H2|_T2] = T,
            {get, H2};
        H == "Host:" ->
            {host, T};
        H == "User-Agent:" ->
            {useragent, T};
        H == "Accept:" -> 
            {accept, T};
        H == "Accept-Language:" ->
            {acceptlanguage, T};
        H == "Accept-Charset:" ->
            {acceptcharset, T};
        true -> 
            net_takoy_bukvi
    end.

%%%===================================================================
%%% запрашиваем порт
%%%===================================================================

request_port() ->
    _Port_config = gs_config2:get_port().
