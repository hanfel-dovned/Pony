/-  *pony, pals
/+  dbug, default-agent, server, schooner
/*  pony-ui     %html  /app/pony-ui/html
/*  thread-ui   %html  /app/thread-ui/html
/*  search-ui    %html  /app/search-ui/html
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 =threads =drafts =scheduled =mypals]
+$  card  card:agent:gall
--
%-  agent:dbug
^-  agent:gall
=|  state-0
=*  state  -
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %.n) bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
  :~
    :*  %pass  /newpals  %agent
        [our.bowl %pals]  %watch  /targets
    ==  
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
          [%apps %pony @ %t ~]
        =/  id  `@da`(slav %da +14:site)
        =/  oldt  ^-  thread  (~(got by threads) id)
        =/  newt  oldt(read %.y)
        :_  state(threads (~(put by threads) id newt))
        (send [200 ~ [%html thread-ui]])
          ::
          [%apps %pony %search @ ~]
        :_  state
        (send [200 ~ [%html search-ui]])
      == 
    ==
  ::
  ++  enjs-state
    =,  enjs:format
    |=  $:
            =^threads
            =^drafts
            =^scheduled
            =^mypals
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
          %+  turn  ~(tap in participants:thread)
          |=  part=@p  [%s (scot %p part)]
          ::
          :-  %a
          %+  turn  ~(tap in voyeurs:thread)
          |=  voy=@p  [%s (scot %p voy)]
          ::
          [%s folder:thread]
          ::
          :-  %a
          %+  turn  ~(tap in tags:thread)
          |=  tag=@t  [%s tag]
          ::
          [%b read:thread]
      ==
      ::
      :-  %a
      %+  turn  drafts
      |=  [title=@t text=@t parts=(set @p) voys=(set @p)]
      :-  %a
      :~
          [%s title]
          [%s text]
          ::
          :-  %a
          %+  turn  ~(tap in parts)
          |=  part=@p  [%s (scot %p part)]
          ::
          :-  %a
          %+  turn  ~(tap in voys)
          |=  voy=@p  [%s (scot %p voy)]
      ==
      ::
      :-  %a
      %+  turn  ~(tap in mypals)
      |=  pal=@p
      [%s (scot %p pal)]
    ==
  ::
  ++  dejs-action
    =,  dejs:format
    |=  jon=json
    ^-  action
    %.  jon
    %-  of
    :~  [%add-ship (at ~[(se %da) (se %p)])]  
        [%new-message (at ~[(se %da) so])]
        [%new-draft (at ~[so so (as (se %p)) (as (se %p))])]
        [%delete-draft (at ~[so so (as (se %p)) (as (se %p))])]
        [%new-thread (at ~[so so (as (se %p)) (as (se %p))])]
        [%fork-thread (at ~[(se %da) (as (se %p)) (as (se %p))])]
        [%move-to-folder (at ~[(se %da) so])]
        [%add-tags (at ~[(se %da) (as so)])]
        [%remove-tag (at ~[(se %da) so])]
        [%schedule-send (at ~[(se %da) so so (as (se %p)) (as (se %p))])]
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
            ~[[now.bowl text:action our.bowl]]
            (~(put in participants:action) our.bowl)
            voyeurs:action
            'Threads'
            ~
            %.n
        ==
      :_  state(threads (~(put by threads) now.bowl newt))
      =-  -.-
      %^  spin  ~(tap in (~(uni in participants:action) voyeurs:action))
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
        %=  oldt
          title  (crip (weld (trip title:oldt) " [fork]"))
          host  our.bowl
          participants  (~(put in participants:action) our.bowl)
          voyeurs  voyeurs:action
          folder  'Threads'
          tags  ~
          read  %.n
        ==
      :_  state(threads (~(put by threads) now.bowl newt))
      =-  -.-
      %^  spin  ~(tap in (~(uni in participants:action) voyeurs:action))
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
      ?.  =(host:oldt our.bowl)
        ?>  =(our.bowl src.bowl)
        :_  state
        :~  :*  %pass  /addship  %agent  
                [host:oldt %pony]
                %poke  %pony-action
                !>([%add-ship id:action ship:action])
            ==
        ==
      ::
      ?>  (~(has in participants:oldt) src.bowl)
      ?<  (~(has in participants:oldt) ship:action)
      =/  newparticipants
          (~(put in participants:oldt) ship:action)
      =/  newt
        ^-  thread
        %=  oldt
          ::  If this came from a voyeur, reveal them
          participants  
            ?.  (~(has in voyeurs:oldt) src.bowl)
              newparticipants
            (~(put in newparticipants) src.bowl)
          ::
          voyeurs
            ?.  (~(has in voyeurs:oldt) src.bowl)
              voyeurs:oldt
            (~(del in voyeurs:oldt) src.bowl)
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
    ::  If participant: forward poke to host.
    ::  If host: append message to thread.
        %new-message
      =/  oldt  
        ^-  thread  
        (~(got by threads) id:action)
      ?.  =(host:oldt our.bowl)
        ?>  =(our.bowl src.bowl)
        :_  state
        :~  :*  %pass  /post  %agent
                [host:oldt %pony]
                %poke  %pony-action
                !>([%new-message id:action text:action])
            ==
        ==
        ::
      ?>  ?|  (~(has in participants:oldt) src.bowl)
              (~(has in voyeurs:oldt) src.bowl)
          ==
      =/  newmessage
        :+  now.bowl
        text:action
        src.bowl  
      =/  newt  
        ^-  thread
        %=  oldt
          messages  (snoc messages:oldt newmessage)
          ::  If this came from a voyeur, reveal them
          participants
            ?.  (~(has in voyeurs:oldt) src.bowl)
              participants:oldt
            (~(put in participants:oldt) src.bowl)
          ::
          voyeurs
            ?.  (~(has in voyeurs:oldt) src.bowl)
              voyeurs:oldt
            (~(del in voyeurs:oldt) src.bowl)
        ==
      :_  state(threads (~(put by threads) id:action newt))
      :~  :*  %give  %fact  ~[/(scot %da id:action)]
              %pony-update 
              !>(`update`[%thread id:action newt(voyeurs ~)])
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
      `state(drafts (oust [+.i 1] drafts))
    ::
    ::  Change a thread's folder.
        %move-to-folder
      ?>  =(src.bowl our.bowl)
      =/  oldt  
        ^-  thread  
        (~(got by threads) id:action)
      =/  newt
        %=  oldt
          folder  folder:action
        ==
      `state(threads (~(put by threads) id:action newt))
    ::
    ::  Add tags to a thread.
        %add-tags
      ?>  =(src.bowl our.bowl)
      =/  oldt  
        ^-  thread  
        (~(got by threads) id:action)
      =/  newt
        %=  oldt
          tags  (~(uni in tags:oldt) tags:action)
        ==
      `state(threads (~(put by threads) id:action newt))
    ::
    ::  Remove a tag to a thread.
        %remove-tag
      ?>  =(src.bowl our.bowl)
      =/  oldt  
        ^-  thread  
        (~(got by threads) id:action)
      =/  newt
        %=  oldt
          tags  (~(del in tags:oldt) tag:action)
        ==
      `state(threads (~(put by threads) id:action newt))
    ::
    ::  Use Behn to schedule a new-thread poke.
        %schedule-send
      ?>  =(src.bowl our.bowl)
      :_  state(scheduled (~(put by scheduled) now.bowl draft:action))
      :~  [%pass /timers/(scot %da now.bowl) %arvo %b %wait when:action]
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
    =/  th
        ^-  thread  
        (~(got by threads) theid)
    ?>  ?|  (~(has in participants:th) src.bowl)
            (~(has in voyeurs:th) src.bowl)
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
      [%newpals ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %pals-effect
        =/  neweffect  !<(effect:pals q.cage.sign)
        ?+    -.neweffect  (on-agent:def wire sign)
            %meet
          `this(mypals (~(put in mypals) +.neweffect))
            %part
          `this(mypals (~(del in mypals) +.neweffect))
        ==
      ==
    ==
    ::
      [%updates @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %pony-update
        =/  newupdate  !<(update q.cage.sign)
        ?-    -.newupdate
            %thread
          ?>  =(id:newupdate (slav %da +6:wire))
          ?.  (~(has by threads) id:newupdate)
            :: this branch is where to insert pals tags
            `this(threads (~(put by threads) id:newupdate thread:newupdate))
          =/  oldt  ^-  thread
            (~(got by threads) id:newupdate)
          =/  newt  thread:newupdate
          =.  newt
            %=  newt
              folder  folder:oldt
              tags  tags:oldt
              read  %.n
            ==
          `this(threads (~(put by threads) id:newupdate newt))
        ==
      ==
      ::
      ::  Not quite sure this is right. 
      ::  If people have issues getting updates, 
      ::  check this first.
        %kick
      :_  this
      :~  :*  %pass   wire
              %agent  [src.bowl %pony]
              %watch  /(scot %da +6:wire)
          ==
      ==
    ==
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timers @ ~]
    ?+    sign-arvo  (on-arvo:def wire sign-arvo)
        [%behn %wake *]
      =/  ndraft  ^-  draft  (~(got by scheduled) (slav %da +6:wire))
      :_  this(scheduled (~(del by scheduled) (slav %da +6:wire)))
      :~  :*  %pass  /new-thread
              %agent  [our.bowl %pony]
              %poke  %pony-action
              !>([%new-thread title:ndraft text:ndraft participants:ndraft voyeurs:ndraft])
      ==  ==
    ==
  ==
::  
++  on-fail  on-fail:def
--