-module (parsing).

-export ([pars/1]).


%% кто вызывает этот модуль? 
%% кто-то должен увеличивать К
%% go_recv?
%% на сокет построчно приходит??
%% -----------------------------

%% pars (<<List>>, K) -> 
%%     if 
%%         K==1 ->
%%             pars_st1 (binary:split (<<List>>, <<" ">>, [global]), []);
%%         K > 1 ->
%%             pars_st (binary:split(<<List>>, <<":">>), [])
%%     end.     

pars (List) -> 
    List2 = string:tokens(List, "\r\n"),
    io:format("List2=~p~n", [List2]),
    pars1(List2, 1, []).

pars1 ([], _K, Acc) -> Acc; %%нужно вернуть аккумулятор
pars1 ([H|T], K, Acc) ->
    if 
        K==1 ->
            Str = pars_st1 (string:tokens(H, " ")),
            Acc=[Str|Acc];
        K > 1 ->
            Str1= pars_stn (string:tokens(H, ": ")),
            Acc=[Str1|Acc]
    end,
    pars1(T, K+1, Acc).


pars_st1 ([H,H2|T]) ->
    _Url2 =
        if 
            H == "GET" ->
                if 
                    T =="HTTP/1.0" -> 
                       H2
%%                        io:format("Location=~p~n", [H2]),
                        ;
                    true -> error
                end;
            true -> error
        end.



pars_stn ([H|T]) ->
    _Url1 =
        if 
            H == "Host" ->
                T;
%%        io:format("Host=~p~n", [T]);
            true -> error
        end.





%% GET / HTTP/1.1
%% Host: example.com
%% User-Agent: MyLonelyBrowser/5.0
%% Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
%% Accept-Language: ru,en-us;q=0.7,en;q=0.3
%% Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.7
