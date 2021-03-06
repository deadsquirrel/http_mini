%%%-------------------------------------------------------------------
%%% @author Yana P. Ribalchenko <yanki@hole.lake>
%%% @copyright (C) 2015, Yana P. Ribalchenko
%%% @doc
%%%       My skeleton gen_server
%%% @end
%%% Created :  9 Nov 2015 by Yana P. Ribalchenko <yanki@hole.lake>
%%%-------------------------------------------------------------------
-module(gs_content).

-behaviour(gen_server).

-define(VERSION, 0.01).
-define (TIMEOUT, 5000).
-define (PORT, 8080).

%% API
-export([
         start_link/0,
         get_state/0,
%%         set_content/1,
%%         get_cont/0,
         get_content/1
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(content_item,
        {
          content_key                    :: any (),
          content_type = <<"text/html">> :: binary(),
          content_size                   :: integer(),
          data = <<>>                    :: binary()
        }).

-record(state,
        {
          req_processed = 0 :: integer(),
          content :: [ #content_item{} ]
        }).

%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    io:format("gs_content gen_server start_link_content (pid ~p)~n", [self()]),
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%--------------------------------------------------------------------
%% @doc just a demo of a API call
%% @end
%%--------------------------------------------------------------------
-spec get_state() -> #state{}.
get_state() ->
    io:format("get_state/0, pid: ~p~n", [self()]),
    gen_server:call(?SERVER, get_me_state).

%% тут хочу установить какой именно файл будем передавать, как контент 
%% сделала по новому
%% -spec set_content(FileIn :: any()) -> ok.
%% set_content(FileIn) ->
%%     io:format("set_cont/1, pid: ~p, ~p~n", [self(), FileIn]),
%%     gen_server:call(?SERVER, {set_content, FileIn}).


%% получаем контент tcp_serv`ом
get_content(GetKey) ->
     io:format("get_content/0, pid: ~p~n", [self()]),
     gen_server:call(?SERVER, {get_content_sent, GetKey}).


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    io:format("http_mini_content gen_server init fun (pid ~p)~n", [self()]),
    {ok, FC} = application:get_env(http_mini, fileouts),
%%    io:format("FileOut = ~p~n", [FC]),
    Ral = readlist(FC, []),
%%    io:format("Ral = ~p~n", [Ral]), 
    {ok, #state{content = Ral}}.


readlist([], Acc) -> Acc;
readlist([{Key, H}|T], Acc) -> 
    {ok, Readfile} = file:read_file(H),
    %% смену типов надо вставить
    %%    Type = #state.content#content_item.content_type,
    Type = get_type(H),
    readlist(T, [#content_item{content_key=Key,
                               content_type = Type, 
                               content_size =byte_size(Readfile),     
                               data = Readfile}|Acc]).

%% получаем тип передаваемого файла
%% проверяем его
    
get_type(File) ->
    [Tail_File, _] = string:tokens(lists:reverse(File), "."),
    L = lists:reverse(Tail_File),
io:format ("L=~p~n", [L]),
    case L of
        "html" -> "text/html";
        "htm" -> "text/html";
        "css" -> "text/css";
        "txt" -> "text/plain";
        "jpg" -> "image/jpeg";
        "jpeg" -> "image/jpeg";
        "jpe" -> "image/jpeg";
        "gif" -> "image/gif";
        "tgz" -> "application/x-compressed";
        "mov" -> "video/quicktime";
        "mpg" -> "video/mpeg";
        _ -> "unknowntype"
    end.

  


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(get_me_state, _From, State) ->
    CurrNum = State#state.req_processed,
    {reply, {takeit, State}, State#state{req_processed = CurrNum +1}};

handle_call({get_content_sent, GetKey}, _From, State) ->
    Fin = State#state.content,
    [Reply]= sorting (Fin, GetKey, []),
%%    io:format("Reply: ~p~n", [Reply]),
    Reply,
    {reply,  Reply,  State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
sorting ([], _Key, AccPar)  -> 
%%     io:format("Keycont == ~p Par = ~p~n", [Key, AccPar]), 
    AccPar;
sorting ([{content_item, H, Type, Size, Par}|_], Key, AccPar) when H==Key -> 
%%    io:format("Keycont~p => Type ~p= Size ~p, Par~p~n", [Key, Type, Size, Par]),
    [{Size, Type, Par}|AccPar];
sorting ([_H|TListHosts], Key, AccPar) -> 
     sorting (TListHosts, Key, AccPar).

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
