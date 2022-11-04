|%
+$  id  @da
+$  message  [date=@da text=@t sender=@p]
+$  participants  (list @p)
+$  voyeurs  (list @p)
+$  thread  :*  =id
                host=@p 
                messages=(list message) 
                =participants
                =voyeurs
            == 
+$  action
  $%  [%new-thread =message =participants =voyeurs]
      [%fork-thread =id =participants =voyeurs]
      [%add-ship =id =ship]
      [%invite =id]
      [%new-message text=@t =id]
      [%post text=@p =id]
  == 
--