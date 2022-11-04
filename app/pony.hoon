/-  *pony
/+  dbug, default-agent, server, schooner
/*  pony-ui  %html  /app/pony-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 threads=(list thread)]
+$  card  card:agent:gall
--
%-  agent:dbug
^-  agent:gall
=|  state-0
=*  state  -
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
    hc    ~(. +> bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
  :~
    :*  %pass  /eyre/connect  %arvo  %e
        %connect  `/apps/pony  %pony
    ==
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  (on-poke:def mark vase)
      %pony-action
    =/  action  !<(action vase)
    =^  cards  state
      (handle-action action)
    [cards this]
    ::  %handle-http-request
    ::?>  =(src.bowl our.bowl)
    ::=^  cards  state
    ::  (handle-http !<([@ta =inbound-request:eyre] vase))
    ::[cards this]
  ==
  ++  handle-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
    ::
    ::  Update state with new thread and invite participants
        %new-thread
      ?>  =(src.bowl our.bowl)
      =/  newthread  ^-  thread  
                     :*  now.bowl
                         title:action
                         our.bowl
                         ~[message:action]
                         participants:action
                         voyeurs:action
                     ==
      `state(threads (into threads 0 newthread))
    ::  invite cards here
    ::
    ::  Duplicate thread and invite new participants
        %fork-thread
      ?>  =(src.bowl our.bowl)
      =/  oldthread  (find-thread:hc id:action)
      =/  newthread  ^-  thread
                     :*  now.bowl
                         title:oldthread
                         our.bowl
                         messages:oldthread
                         participants:action
                         voyeurs:action
                     ==
      `state(threads (into threads 0 newthread))
    ==
  --
++  on-peek  on-peek:def
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%http-response *]
    `this
  ==
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-arvo  on-arvo:def
++  on-fail  on-fail:def
--
::
|_  bowl:gall
++  find-thread
  |=  =id
  ^-  thread
  %+  snag  0
  %+  skim  threads
  |=  t=thread
  =(-.t id)
--