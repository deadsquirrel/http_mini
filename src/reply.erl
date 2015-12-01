-module (reply).

-export ([create_reply_header/0]).

%% -spec create_reply_headers(RespCode::integer(), Html::binary()) ->
%%                                   [HeaderString::binary()].


create_reply_header () ->
    [<<"HTTP/1.0 200 OK">>, 
     <<"\r\n">>, 
     list_to_binary(serverName()),<<"\r\n">>,
     list_to_binary(httpd_util:rfc1123_date()),
     <<"\r\n">>, 
     <<"Content-Type: text/html">>, <<"\r\n">>, 
     
<<"Content-Length: 13">>,
     <<"\r\n\r\n">>].

serverName () ->
    {ok, Name} = application:get_env (http_mini, servername),
    Name.



%% Date
%% httpd_util:rfc1123_date()
%% HTTP
%% http_d:http_version
%% httpd_util:reason_phrase(200)
