/-  *pony
/+  dbug, default-agent, server, schooner
/*  pony-ui     %html  /app/pony-ui/html
/*  thread-ui   %html  /app/thread-ui/html
/*  draft-ui    %html  /app/draft-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 =threads =drafts]
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
      %handle-http-request
    ?>  =(src.bowl our.bowl)
    =^  cards  state
      (handle-http !<([@ta =inbound-request:eyre] vase))
    [cards this]
  ==
  ::
  ++  handle-http
    |=  [eyre-id=@ta =inbound-request:eyre]
    ^-  (quip card _state)
    =/  ,request-line:server
      (parse-request-line:server url.request.inbound-request)
    =+  send=(cury response:schooner eyre-id)
    ?.  authenticated.inbound-request
      :_  state
      %-  send
      [302 ~ [%login-redirect './apps/pony']]
    ::
    ?+    method.request.inbound-request  
      [(send [405 ~ [%stock ~]]) state]
      ::
        %'POST'
      ?.  authenticated.inbound-request
        :_  state
        %-  send
        [302 ~ [%login-redirect './apps/pony']]
      ?~  body.request.inbound-request
        [(send [405 ~ [%stock ~]]) state]
      =/  json  (de-json:html q.u.body.request.inbound-request)
      =/  action  (dejs-action +.json)
      (handle-action action) 
      ::
        %'GET'
      ?+    site  
          :_  state 
          (send [404 ~ [%plain "404 - Not Found"]])
          ::
          [%apps %pony ~]
        :_  state
        (send [200 ~ [%html pony-ui]])
          ::
          [%apps %pony %state ~]
        :_  state
        (send [200 ~ [%json (enjs-state +.state)]])
          ::
          [%apps %pony @da ~]
        :_  state
        (send [200 ~ [%html thread-ui]])
          ::
          [%apps %pony %drafts @da ~]
        :_  state
        (send [200 ~ [%html draft-ui]])
      == 
    ==
  ::
  ++  enjs-state
    =,  enjs:format
    |=  $:
            =^threads
            =^drafts
        ==
    ^-  json
    :-  %a
    :~
      :-  %a
      %+  turn
        ~(tap by threads)
      |=  [=id =thread]
      :-  %a
      :~
          [%s (scot %da id)]
          [%s title:thread]
          [%s (scot %p host:thread)]
          ::
          :-  %a
          %+  turn  messages:thread
          |=  =message
          :-  %a
          :~
            [%s (scot %da date:message)]
            [%s text:message]
            [%s (scot %p sender:message)]
          ==
          ::
          :-  %a
          %+  turn  participants:thread
          |=  part=@p  [%s (scot %p part)]
          ::
          :-  %a
          %+  turn  voyeurs:thread
          |=  voy=@p  [%s (scot %p voy)]
      ==
      ::
      :-  %a
      %+  turn  drafts
      |=  [=id text=@t]
      :-  %a
      :~
          [%s (scot %da id)]
          [%s text]
      ==
    ==
  ::
  ++  dejs-action
    =,  dejs:format
    |=  jon=json
    ^-  action
    %.  jon
    %-  of
    :~  [%add-ship (at ~[(se %da) (se %p)])]  
        ::[%delete-page so]
    ==
  ::
  ++  handle-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
    ::
    ::  Update state with new thread and invite participants.
        %new-thread
      ?>  =(src.bowl our.bowl)
      =/  newt
        ^-  thread  
        :*  title:action
            our.bowl
            ~[message:action]
            (snoc participants:action our.bowl)
            voyeurs:action
        ==
      :_  state(threads (~(put by threads) now.bowl newt))
      =-  -.-
      %^  spin  (weld participants:action voyeurs:action)
          now.bowl
      |=  [=ship id=@da]
      :_  id
      :*  %pass  /invites  %agent
          [ship %pony]
          %poke  %pony-action
          !>([%invite id])  
      ==
    ::
    ::  Duplicate thread and invite new participants.
        %fork-thread
      ?>  =(src.bowl our.bowl)
      =/  oldt  
        ^-  thread  (~(got by threads) id:action)
      =/  newt
        ^-  thread
        :*  title:oldt
            our.bowl
            messages:oldt
            (snoc participants:action our.bowl)
            voyeurs:action
        ==
      :_  state(threads (~(put by threads) now.bowl newt))
      =-  -.-
      %^  spin  (weld participants:action voyeurs:action)
          now.bowl
      |=  [=ship id=@da]
      :_  id
      :*  %pass  /invites  %agent
          [ship %pony]
          %poke  %pony-action
          !>([%invite id])  
      ==
    ::
    ::  If host: add ship to thread as participant.
    ::  If participant: forward this poke to the host.
        %add-ship
      =/  oldt  
          ^-  thread  
          (~(got by threads) id:action)
      ?:  =(host:oldt our.bowl)
        ?>  (is-member participants:oldt src.bowl)
        ?<  (is-member participants:oldt ship:action)
        =/  newparticipants
            (snoc participants:oldt ship:action)
        =/  newt
          ^-  thread
          :*  title:oldt
              host:oldt
              messages:oldt
              newparticipants
              ?.  (is-member voyeurs:oldt src.bowl)
                voyeurs:oldt
              %+  oust
                :-  =<  +
                    %+  find  
                      ~[src.bowl]
                    voyeurs:oldt
                1
              voyeurs:oldt
          ==
        :_  state(threads (~(put by threads) id:action newt))
        :~  :*  %pass  /invites  %agent
                [ship:action %pony]
                %poke  %pony-action
                !>([%invite id:action])  
            ==
            :*  %give  %fact  ~[/(scot %da id:action)]
                %pony-update 
                !>(`update`[%thread id:action newt(voyeurs ~)])
            ==
        ==
        ::
      ?>  =(our.bowl src.bowl)
      :_  state
      :~  :*  %pass  /addship  %agent  
              [host:oldt %pony]
              %poke  %pony-action
              !>([%add-ship id:action ship:action])
          ==
      ==
    ::
    ::  Remote hosts call this to add me to a thread.
        %invite
      ?<  (~(has by threads) id:action)
      :_  state
      :~  :*  %pass  /updates/(scot %da id:action)
              %agent  [src.bowl %pony]
              %watch  /(scot %da id:action)
          ==
      ==
    ::
    ::  If host: append message to thread.
    ::  If participant: forward poke to host.
        %new-message
      =/  oldt  
        ^-  thread  
        (~(got by threads) id:action)
      ?:  =(host:oldt our.bowl)
        ?>  ?|  (is-member participants:oldt src.bowl)
                (is-member voyeurs:oldt src.bowl)
            ==
        =/  newmessage
          :+  now.bowl
          text:action
          src.bowl  
        =/  newt  
          ^-  thread
          :*  title:oldt
              host:oldt
              (snoc messages:oldt newmessage)
              ?.  (is-member voyeurs:oldt src.bowl)
                :-  participants:oldt
                voyeurs:oldt
              :-  (snoc participants:oldt src.bowl)
              %+  oust
                :-  =<  +
                    %+  find  
                      ~[src.bowl]
                    voyeurs:oldt
                1
              voyeurs:oldt
          ==
        :_  state(threads (~(put by threads) id:action newt))
        :~  :*  %give  %fact  ~[/(scot %da id:action)]
                %pony-update 
                !>(`update`[%thread id:action newt(voyeurs ~)])
            ==
        ==
        ::
      ?>  =(our.bowl src.bowl)
      :_  state
      :~  :*  %pass  /post  %agent
              [host:oldt %pony]
              %poke  %pony-action
              !>([%post id:action text:action])
          ==
      ==
      ::
      ::  Save a draft.
          %new-draft
        ?>  =(src.bowl our.bowl)
        `state(drafts (snoc drafts draft:action))
      ::
      ::  Delete a draft.
          %delete-draft
        ?>  =(src.bowl our.bowl)
        =/  i  (find ~[draft:action] drafts)
        `state(drafts (oust [+.i 0] drafts))
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
    =/  th
        ^-  thread  
        (~(got by threads) theid)
    ?>  ?|  (is-member participants:th src.bowl)
            (is-member voyeurs:th src.bowl)
        ==
    :_  this
    :~  :*  %give  %fact  ~
            %pony-update 
            !>(`update`[%thread theid th(voyeurs ~)])
        ==
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