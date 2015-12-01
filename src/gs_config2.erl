%%%-------------------------------------------------------------------
%%% @author Yana P. Ribalchenko <yanki@hole.lake>
%%% @copyright (C) 2015, Yana P. Ribalchenko
%%% @doc
%%%       My skeleton gen_server
%%% @end
%%% Created :  9 Nov 2015 by Yana P. Ribalchenko <yanki@hole.lake>
%%%-------------------------------------------------------------------
-module(gs_config2).

-behaviour(gen_server).

-define(VERSION, 0.01).
-define (TIMEOUT, 5000).


%% API
-export([
         start_link/0,
         get_state/0,
         get_port/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state,
        {
          req_processed = 0 :: integer (),
          port_connect :: integer ()
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
    io:format("gs_config2 gen_server start_link_config (pid ~p)~n", [self()]),
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%--------------------------------------------------------------------
%% @doc just a demo of a API call
%% @end
%%--------------------------------------------------------------------
-spec get_state() -> #state{}.
get_state() ->
    gen_server:call(?SERVER, get_me_state).


%%%===================================================================
%%% цикл приема, отфильтровываем запрос от tcp_serv
%%%===================================================================
get_port() -> 
    gen_server:call(?SERVER, request_port).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    io:format("http_mini_config2 gen_server init fun (pid ~p)~n", [self()]),
    PC = application:get_env (http_mini, port2),
    {ok, #state{port_connect = PC}}.


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

handle_call(request_port, _From, State) ->
    Port_conn = State#state.port_connect,
    {reply, Port_conn, State};
    
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

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


