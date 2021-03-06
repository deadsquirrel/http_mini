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
        {ok, Request} ->
%% not sure --------------
%%            receive_data(Sock, []),
%% end of not sure --------
%%            gs_logger:yanki(Request),
            String = binary_to_list(Request),
            io:format("String = ~p~n", [String]),
            io:format("Request = ~p~n", [Request]),
            [H|_T] = string:tokens(String, " "),
%%            io:format("Head = ~p~n", [H]),
%%            io:format("Tail = ~p~n", [T]),
            Proplist = 
                if H == "GET" ->
%% может запустить тут процесс
                        parsing(String);
                        %% Pid = spawn (http_mini_tcp_serv, parsing, [Stroka] ),
                        %% io:format("Parsing Pid=~p~n", [Pid]);
                   true -> xpenb
                end,
            
            %% проверку по проплисту
            %% если результат ожидаемый, отдаем файл
            
%%            Outfile = gs_content:get_content(),
%% OutFile тут равен FileOut из функции. т.е. список
%% берем из списка кусок ниже
%% ----------------------------------------------------------------------------
%%  из *app.src получаем следующие параметры параметры для сравнения
%% ----------------------------------------------------------------------------
            {ok, Port} = application:get_env (http_mini, port), 
            io:format("Port = ~p~n", [Port]), 
            %% "localhost"
%%% кажется они тут не нужны, будем проверять на ходу соответствие Key - Value
%%             {ok, Adress} = application:get_env (http_mini, host), 
%%             io:format("Adress =~p~n ", [Adress]), 
%%             {ok, File} = application:get_env (http_mini, file),
%%             io:format("File = ~p~n", [File]), 
%% %%            {ok, Reply} = application:get_env (http_mini, fileout),
%%             io:format("ACHTUNG! Reply = ~p~n", [Outfile]), 
%% ----------------------------------------------------------------------------
%%  парсим proplist
%% ----------------------------------------------------------------------------

            %%  "/about.html"
            Get = proplists:get_value(get, Proplist), 
            io:format("Get  = ~p~n", [Get]), 
            %%  "localhost:8888"
            [Host] =  proplists:get_value(host, Proplist), 
%%% тут надо оптимизировать - в одну строку написать, а то 
            [Host2|[P]] = string:tokens(Host, ":"),
            io:format("Host2 = ~p~n", [Host2]), 
            Port2= list_to_integer(P),
            io:format("Port2 = ~p~n", [Port2]), 
            %% Adress,
            %% File,
            Get,
            Host2,
            Port2,
            UserAgent = proplists:get_value(useragent, Proplist),
%% ----------------------------------------------------------------------------
%% сравниваем HFPJ,HFNM!
%% ----------------------------------------------------------------------------
            if
                Port == Port2 ->
                    {ok, ListHosts} = application:get_env (http_mini, hosts),
                            io:format("ListHosts  ~p~n", [ListHosts]), 

                    %% Есть список адресов в кей-валюе структуре
                    %% найти соответствие
                    %% делаем перенаправление. либо тут вызываем обработку файла дальше и отдаем 200 ок
                    case sorting (ListHosts, Host2) of
                        nothing ->
                            gen_tcp:send (Sock,responce(thirtyfour, Get, nothing, UserAgent)),
                            gen_tcp:close(Sock);
%% кажется это полная фигня. просто ищем по другому ключу и все прописано в конфиге
                      %%   {redirect, Param302} ->
%% %% если хост2 иной, но существующий, пересылаем на главную и смотрим, что именно 
%% %% запрашивает пользователь - отдаем ему запрашиваемый файл, если он есть
%%                             io:format("Param302 >>  ~p~n", [Param302]), 
%%                             {ok, Filesout} = application:get_env (http_mini, fileouts),
%%                             io:format("Filesout  ~p~n Get=~p~n", [Filesout, Get]), 
%%                             Filesout,
%%                             case sorting (Filesout, Get) of
%%                                 nothing -> 
%%                                     gen_tcp:send (Sock, responce(fortyfour, ups, nothing, UserAgent)),
%%                                     gen_tcp:close(Sock);
                                
%%                                 Param2 -> 
%%                                     io:format("Param2 >>  ~p~n", [Param2]),     
%% %% редирект 302 на главную
%%                                     gen_tcp:send (Sock,responce(thirtyhuntwo, Get, Param302, UserAgent)),
%%                                     gen_tcp:close(Sock)
%%                                         end;
                        Param ->
                            io:format("Param >>  ~p~n", [Param]), 
                            {ok, Filesout} = application:get_env (http_mini, fileouts),
                            io:format("Filesout  ~p~n Get=~p~n", [Filesout, Get]), 
                            Filesout,
                            case sorting (Filesout, Get) of
                                nothing -> 
                                    gen_tcp:send (Sock, responce(fortyfour, ups, nothing, UserAgent)),
                                    gen_tcp:close(Sock);
                                
                                Param2 -> 
                                    io:format("Param2 >>  ~p~n", [Param2]),        
                       
%% ----------------------------------------------------------------------------
%%  Param2 - url для передачи в лог-файл
%% ----------------------------------------------------------------------------

                                    gen_tcp:send (Sock,responce(twohundred, Get, Param, UserAgent)),
                                    gen_tcp:close(Sock)
                            end
                    end;
                %%                     case application:get_key(Host2) of 
%%                         undefined -> 
%%                             io:format("Ups. no host  ~p~n", [Host2]), 
%% %%% Outfile тожу пока список, но попробуем отдаьт его пока так.
%% %%% Поправить!!
%%                             gen_tcp:send (Sock,responce(thirtyfour, Outfile)),
%%                             gen_tcp:close(Sock);
%%                         {ok, Val}   -> Val,
%%                                        io:format("Val = ~p~n", [Val]), 
%%                                        gen_tcp:send (Sock, responce(twohundred, Val)),     
%%                                        gen_tcp:close(Sock)
%%                     end;
                true  ->
                    gen_tcp:send (Sock,responce(thirtyfour, nothing, nothing, UserAgent)),
                    gen_tcp:close(Sock)
            end,
            go_recv(Sock);
        
        _Oth ->
            %% здесь Reply еще не известна, надо объявить где-то еще,
            %% или написать вручную. пока что
            %%            gen_tcp:send (Sock, Reply),
            gen_tcp:send (Sock, <<"HTTP/1.x 434 Requested host unavailable\r\nServer: Yankizaur/0.1.1\r\n\r\n<html><head></head><body>host not available</body></html>\r\n">>),
            gen_tcp:close(Sock)
    end.

responce(fortyfour, GetKey, Url, UserAgent) ->
    {Size, Type, Outfile} = gs_content:get_content(GetKey),
    io:format ("Size=~p, Type: ~p~n", [Size, Type]),
    LocalDate = httpd_util:rfc1123_date(),
    U = to_log(LocalDate, Url, UserAgent),
    gs_logger:writer(U),
    create_reply_header(Size, Type, LocalDate)++Outfile;
responce(thirtyfour, _Resp, _Url, _UserAgent) ->
    <<"HTTP/1.x 434 Requested host unavailable\r\nServer: Yankizaur/0.1.1\r\n\r\n<html><head></head><body>host not available</body></html>\r\n">>;
%% на вход пришло Get="/about.html"
responce(twohundred, GetKey, Url, UserAgent) ->
    %% надо по ключу получить содержимое рекорда
   {Size, Type, Outfile} = gs_content:get_content(GetKey),
    io:format ("Size=~p, Type: ~p~n", [Size, Type]),
    LocalDate = httpd_util:rfc1123_date(),
    U = list_to_binary(to_log(LocalDate, Url, UserAgent)),
    gs_logger:writer(U),
    create_reply_header(Size, Type, LocalDate)++Outfile;

%% responce(thirtyhuntwo, GetKey, Url, UserAgent) ->
%%    {Size, Type, Outfile} = gs_content:get_content(GetKey),
%%     io:format ("Size=~p, Type: ~p~n", [Size, Type]),
%%     LocalDate = httpd_util:rfc1123_date(),
%%     U = list_to_binary(to_log(LocalDate, Url, UserAgent)),
%%     gs_logger:writer(U),
%%     create_reply_header(Size, Type, LocalDate)++Outfile;

responce(_, _Resp, _Url, _UserAgent) ->
    ups.


to_log(LocalDate, Url, UserAgent) ->
    ["[", LocalDate,
     "] GET",
     Url,
     " 200 ",
     UserAgent,
     "\r\n"].

create_reply_header (Gets_size, Gets_type, LocalDate) ->
    [<<"HTTP/1.0 200 OK">>, 
     <<"\r\n">>, 
     <<"Server: ">>,    list_to_binary(serverName()),<<"\r\n">>,
     <<"Data: ">>,     list_to_binary(LocalDate),
     <<"\r\n">>, 
%% content-type должен отдаваться  контент-сервером
     <<"Content-Type:">>,
     Gets_type,
     <<"\r\n">>, 
     <<"Content-Length: ">>, 
%% надо считать содержимое файла, а на фходе у нас ключ!
%% либо в response формировать ответ, который и приходит сюда 
%% -- было вычесление длины прямо тут 
%% v.1
%%     list_to_binary(integer_to_list(byte_size(Getting))),
%% v.2
%% читаем длину из рекорда
     list_to_binary(integer_to_list(Gets_size)),
     <<"\r\n\r\n">>].

serverName () ->
    {ok, Name} = application:get_env (http_mini, servername),
    Name.


%%    lists:reverse
%% create_reply_header2() ->
%%   calendar:datetime

%%%===================================================================
%%% парсим полученные строки 
%%%===================================================================
parsing (List) -> 
    List2 = string:tokens(List, "\r\n"),
%%    io:format("List2=~p~n", [List2]),
    Asdf = pars1(List2, []),
    io:format("asdf = ~p~n", [Asdf]),
    Asdf.

pars1 ([], Acc) -> lists:reverse(Acc);
pars1 ([H|T], Acc) ->
%%    io:format("H = ~p~n", [H]),
    Str= pars_stn (string:tokens(H, " ")),
    Acc2=[Str|Acc],
%%    io:format("Acc2: ~p~n", [Acc2]),
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
%%% получение фрагментами и объединение
%%%===================================================================
%% receive_data(Socket, SoFar) ->
%%     receive {tcp,Socket,Bin} ->
%%             receive_data(Socket, [Bin|SoFar]);
%%             {tcp_closed,Socket} ->
%%             list_to_binary(lists:reverse(SoFar)) end.

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

%% передумала так делать, но пусть пока повисит. 
%% readhost ([{_Host2, Path}|T]) -> Path,
%%                                 readhost (T).
sorting ([], _Key)  -> 
    nothing;
%% sorting ([], Key, AccPar)  -> 
%%     io:format("Key == ~p Par = ~p~n", [Key, AccPar]), 
%%     AccPar;
%% sorting ([{H, Par}|_], Key) when Key == "oldsite"  -> 
%%     io:format("Key~p 0000 => Par ~p~n", [Key, Par]),
%%     {redirect, Par};
sorting ([{H, Par}|_], Key) when H==Key -> 
    io:format("Key~p => Par ~p~n", [Key, Par]),
    Par;
sorting ([_H|TListHosts], Key) -> 
    sorting (TListHosts, Key).

