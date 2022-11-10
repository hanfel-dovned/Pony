|%
+$  id  @da
+$  message  [date=@da text=@t sender=@p]
+$  participants  (list @p)
+$  voyeurs  (list @p)
+$  thread  $:  title=@t
                host=@p 
                messages=(list message) 
                =participants
                =voyeurs
            == 
+$  threads  (map =id =thread)
+$  draft  [=id text=@t]
+$  drafts  (list draft)
+$  action
  $%  [%new-thread title=@t =message =participants =voyeurs]
      [%fork-thread =id =participants =voyeurs]
      [%add-ship =id =ship]
      [%invite =id]
      [%new-message =id text=@t]
      [%new-draft =draft]
  ==
+$  update
  $%  [%thread =id =thread]
  ==
--