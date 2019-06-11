set pages 0
set lines 200
set trimspool on


spool index_rebuild_compress.txt
select 'alter index '||index_name||' rebuild compress advanced low;'
from user_indexes ui
where index_name in ( select index_name
                        from user_ind_columns uic
					   where uic.index_name = ui.index_name
					   group by index_name
					   having count(1) > 1 )
order by 1
/
spool off
