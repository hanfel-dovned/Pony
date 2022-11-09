/-  *pony
/+  dbug, default-agent, server, schooner
/*  pony-ui  %html  /app/pony-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 =threads]
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
    ::  Update state with new thread and invite participants.
        %new-thread
      ?>  =(src.bowl our.bowl)
      =/  newthread  ^-  thread  
                     :*  title:action
                         our.bowl
                         ~[message:action]
                         (snoc participants:action our.bowl)
                         voyeurs:action
                     ==
      `state(threads (~(put by threads) now.bowl newthread))
      ::  invite cards here
    ::
    ::  Duplicate thread and invite new participants.
        %fork-thread
      ?>  =(src.bowl our.bowl)
      =/  oldthread  ^-  thread  (~(got by threads) id:action)
      =/  newthread  ^-  thread
                     :*  title:oldthread
                         our.bowl
                         messages:oldthread
                         (snoc participants:action our.bowl)
                         voyeurs:action
                     ==
      `state(threads (~(put by threads) now.bowl newthread))
      ::invite other ships
    ::
    ::  If host: add ship to thread as participant.
    ::  If participant: forward this poke to the host.
        %add-ship
      =/  thethread  
          ^-  thread  
          (~(got by threads) id:action)
      ?:  =(host:thethread our.bowl)
        ?>  (is-member participants:thethread src.bowl)
        ?<  (is-member participants:thethread ship:action)
        =/  newparticipants  (snoc participants:thethread ship:action)
        =/  newthread  ^-  thread
                       :*  title:thethread
                           host:thethread
                           messages:thethread
                           newparticipants
                           voyeurs:thethread
                       ==
        :_  state(threads (~(put by threads) id:action newthread))
        :~  [%pass /invites %agent [ship:action %pony] %poke %pony-action !>([%invite id:action])]
        ==
      `state
      :: ?>  =(our.bowl src.bowl) ::otherwise participant A could route request to host through B
      :: run add-ship poke on host:thethread
    ::
    ::  Remote hosts call this to add me to a thread.
        %invite
      ?<  (~(has by threads) id:action)
      :_  state
      :~  [%pass /updates/(scot %da id:action) %agent [src.bowl %pony] %watch /(scot %da id:action)]
      ==
    ==
  --
++  on-peek  on-peek:def
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%http-response *]
    `this
  ::
  ::  Watch paths are the ID of the thread
      [@ ~]
    =/  theid  (slav %da -.path)
    =/  thethread  
        ^-  thread  
        (~(got by threads) theid)
    ?>  ?|  (is-member participants:thethread src.bowl)
            (is-member voyeurs:thethread src.bowl)
        ==
    :_  this
    :~  [%give %fact ~ %pony-update !>(`update`[%thread theid thethread])]
    ==
  ==
::
++  on-leave  on-leave:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%updates @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %pony-update
        =/  newupdate  !<(update q.cage.sign)
        ?-    -.newupdate
            %thread
          ?>  =(id:newupdate (slav %da +6:wire))
          `this(threads (~(put by threads) id:newupdate thread:newupdate))
        ==
      ==
        ::  handle kicks by re-subscribing
    ==
  ==
::
++  on-arvo  on-arvo:def
++  on-fail  on-fail:def
--
::
|_  bowl:gall
::++  find-thread
::  |=  =id
::  ^-  thread
::  %+  snag  0
::  %+  skim  threads
::  |=  t=thread
::  =(-.t id)
::
++  is-member
  |=  [members=(list @p) who=@p]
  ^-  ?
  =+  %+  skim  members
      |=  m=@p
      =(m who)
  ?~  -
    %.n
  %.y
--