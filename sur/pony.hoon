|%
+$  id  @da
+$  message  [date=@da text=@t sender=@p]
+$  participants  (set @p)
+$  voyeurs  (set @p)
+$  thread  $:  title=@t
                host=@p 
                messages=(list message) 
                =participants
                =voyeurs
                folder=@t
                tags=(set @t)
                read=?
            == 
+$  threads  (map =id =thread)
+$  draft  [title=@t text=@t =participants =voyeurs]
+$  drafts  (list draft)
+$  scheduled  (map bday=@da =draft)
+$  mypals  (set @p)
+$  action
  $%  [%new-thread title=@t text=@t =participants =voyeurs]
      [%fork-thread =id =participants =voyeurs]
      [%add-ship =id =ship]
      [%invite =id]
      [%new-message =id text=@t]
      [%new-draft =draft]
      [%delete-draft =draft]
      [%move-to-folder =id folder=@t]
      [%add-tags =id tags=(set @t)]
      [%remove-tag =id tag=@t]
      [%schedule-send when=@da =draft]
  ==
+$  update
  $%  [%thread =id =thread]
  ==
--