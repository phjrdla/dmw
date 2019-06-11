set termout off
set colsep &&2
set pagesize 0
set linesize 32000
set trimspool on
set trimout on
set pagesize 0 embedded on
set heading on
set underline off
set feedback on

spool &&1


rem
rem valeurs pour inserts, updates et deletes depuis démarrager de l'instance
rem
rem to run :
rem sqlplus system/xxx!xxxx @d:\solife-db\scripts\ods_tab_modifications.sql
rem
set lines 200
set pages 200
set trimspool on

column "TAB_NAME"    format A40 trunc
column "TAB_INSERTS" format 999,999,999
column "TAB_UPDATES" format 999,999,999
column "TAB_DELETES" format 999,999,999
column "TAB_ROWS"    format 999,999,999
column "TSTAMP"      format a20 trunc

select dtm.table_name "TAB_NAME"
      ,dtm.inserts    "TAB_INSERTS"
      ,dtm.updates    "TAB_UPDATES"
      ,dtm.deletes    "TAB_DELETES"
      ,dt.num_rows    "TAB_ROWS"
      ,to_char(sysdate,'DD-MM-YYYY HH24:MI:SS') "TSTAMP"
  from dba_tables dt, dba_tab_modifications dtm
 where dtm.table_name = dt.table_name
   and dt.owner = dtm.table_owner (+)
   and dt.owner = 'SOLIFE_IT0_ODS'
 order by 1;
 
spool off
quit;
/

