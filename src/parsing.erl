-module (parsing).

-export ([pars/1]).


pars (List) -> 
    List2 = string:tokens(List, "\r\n"),
    io:format("List2=~p~n", [List2]),
    Asdf = pars1(List2, 1, []),
    io:format("asdf = ~p~n", [Asdf]),
    Asdf.


%% pars2([], _, Acc) ->
%%     Acc;
%% pars2([H|T], _, Acc) ->
%%     case 
%%         string:tokens(H, ": ")
%%     of
%%         Tokens when is_list(Tokens) andalso length(Tokens) == 2 ->
%%             [H1|T1] = Tokens,
%%             pars2(T, 1, [{H1,T1}|Acc]);
%%         _Oth ->
%%             io:format("other: ~p~n", [_Oth]),
%%             pars2(T, 1, Acc)
%%     end.


pars1 ([], _K, Acc) -> lists:reverse(Acc);
pars1 ([H|T], K, Acc) ->
    io:format("H = ~p~n K=~p~n", [H, K]),
    
    Acc3 = if 
               K==1 ->
                   Str = pars_st1 (string:tokens(H, " ")),
                   Acc2=[Str|Acc],
                   io:format("Acc11: ~p~n", [Acc]),
                   Acc2;
               K > 1 ->
                   Str1= pars_stn (string:tokens(H, " ")),
                   Acc2=[Str1|Acc],
                   io:format("Acc12: ~p~n", [Acc2]),
                   Acc2
           end,
    io:format("Acc3: ~p~n", [Acc3]),
    pars1(T, K+1, Acc3).


pars_st1 ([H,H2|_T]) ->
    if 
        H == "GET" ->
            {get, H2};
        true -> error
    end.



pars_stn ([H|T]) ->
    if 
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
        


%% GET / HTTP/1.1
%% Host: example.com
%% User-Agent: MyLonelyBrowser/5.0
%% Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
%% Accept-Language: ru,en-us;q=0.7,en;q=0.3
%% Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.7
