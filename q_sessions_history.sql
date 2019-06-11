-- Sessions Count from History

SELECT   rl.snap_id, s.begin_interval_time, s.end_interval_time,

         rl.instance_number, rl.resource_name, rl.current_utilization,

         rl.max_utilization

    FROM dba_hist_resource_limit rl, dba_hist_snapshot s

   WHERE s.snap_id = rl.snap_id AND rl.resource_name = 'sessions'

   and S.BEGIN_INTERVAL_TIME>=to_date('20170312','YYYYMMDD')

   and S.END_INTERVAL_TIME<=to_date('20170314','YYYYMMDD')

ORDER BY s.begin_interval_time, rl.instance_number;

 

-- Processes Count from History

SELECT   rl.snap_id, s.begin_interval_time, s.end_interval_time,

         rl.instance_number, rl.resource_name, rl.current_utilization,

         rl.max_utilization

    FROM dba_hist_resource_limit rl, dba_hist_snapshot s

   WHERE s.snap_id = rl.snap_id AND rl.resource_name = 'processes'

   and S.BEGIN_INTERVAL_TIME>=to_date('20170312','YYYYMMDD')

   and S.END_INTERVAL_TIME<=to_date('20170314','YYYYMMDD')

ORDER BY s.begin_interval_time