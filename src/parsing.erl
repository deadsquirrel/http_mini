-module (parsing).

-export ([pars/2]).

%% кто вызывает этот модуль? 
%% кто-то должен увеличивать К
%% go_recv?
%% на сокет построчно приходит??

pars (<<List>>, K) -> 

    if 
        K==1 ->
            pars_st1 (binary:split (<<List>>, <<" ">>, [global]));
        K > 1 ->
            pars_st (binary:split(<<List>>, <<":">>))
    end.     



pars_st1 ([H,H2|T]) ->
    _Url2 =
        if 
            H == "GET" ->
                if 
                    T =="HTTP/1.0" -> 
                        H2;
                    true -> error
                end;
            true -> error
        end.



pars_st ([H|T]) ->
    _Url1 =
        if 
            H == "Host" ->
                T;
            true -> error
        end.






%% GET / HTTP/1.1
%% Host: example.com
%% User-Agent: MyLonelyBrowser/5.0
%% Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
%% Accept-Language: ru,en-us;q=0.7,en;q=0.3
%% Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.7
