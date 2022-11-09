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
+$  action
  $%  [%new-thread title=@t =message =participants =voyeurs]
      [%fork-thread =id =participants =voyeurs]
      [%add-ship =id =ship]
      [%invite =id]
     ::[%new-message text=@t =id]
     ::[%post text=@p =id]
  == 
+$  update
  $%  [%thread =id =thread]
  ==
--