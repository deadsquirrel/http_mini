%%%-------------------------------------------------------------------
%%% @author Yana P. Ribalchenko <yanki@hole.lake>
%%% @copyright (C) 2015, Yana P. Ribalchenko
%%% @doc
%%%       My supervisor for tree server
%%% @end
%%% Created :  9 Nov 2015 by Yana P. Ribalchenko <yanki@hole.lake>
%%%-------------------------------------------------------------------
-module(http_mini_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    io:format("http_mini_sup start_link/0, pid ~p~n", [self()]),
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


%% start_link(SupName, Module, Args) -> Result 
%% SupName = {local, Name} | {global, Name}

%% aName = atom()
%% Module = atom()
%% Args = term()
%% Result = {ok, Pid} | ignore | {error, Error}
%% аPid = pid()
%% аError = {already_started, Pid}} | shutdown | term() 

%%--------------------------------------------------------------------
%% @doc
%% Starts the child
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------


%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    io:format("http_mini_sup init, pid ~p~n", [self()]),
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    
    Restart = permanent,
    Shutdown = 2000,
    Type = worker,
    %% !! начинаем работать отсюда
    
    AChild_conf = {gs_config_name, {gs_config, start_link, []},
                   Restart, Shutdown, Type, [gs_config]},
    
    AChild_content = {gs_content_name, {gs_content, start_link, []},
                      Restart, Shutdown, Type, [gs_content]},
    
    AChild_tcp_serv = {tcp_serv_name, {mini_http_tcp_serv, start_link, []},
                      Restart, Shutdown, Type, [mini_http_tcp_serv]},
    
    {ok, {SupFlags, [AChild_conf, AChild_content, AChild_tcp_serv]}}.


%%%===================================================================
%%% Internal functions
%%%===================================================================
