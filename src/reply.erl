-module (reply).

-export ([responce/2,
          create_reply_headers/0]).


%% -spec create_reply_headers(RespCode::integer(), Html::binary()) ->
%%                                   [HeaderString::binary()].
                                      
   %%чтобы возвращала список строк в виде бинарей, каждая строка - отдельный
  %%заголовок, типа
                                      

responce("404", _Resp) ->
    <<"HTTP/1.x 404 Not found\r\nServer: localhost/0.1.1\r\n\r\n<html><head></head><body>404 Not found File</body></html>\r\n">>; 
responce("434", _Resp) ->
<<"HTTP/1.x 434 Requested host unavailable\r\nServer: Yankizaur/0.1.1\r\n\r\n<html><head></head><body>host not available</body></html>\r\n">>;
responce("200", _Resp) ->
%%  в оригинальном модуле он есть. потестировать без него либо добавить
    create_reply_header()++Outfile;
responce(_, _Resp) ->
    ups.


create_reply_header () ->
    [<<"HTTP/1.0 200 OK">>, 
     <<"Server: Yanki's cool server/1.0">>,
     <<"Date: Sat, 08 Mar 2014 22:53:46 GMT">>, 
     <<"Content-Type: text/html">>,
     <<"Content-Length: 113">>,
     <<"\r\n\r\n">>].