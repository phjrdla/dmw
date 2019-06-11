<#	
.SYNOPSIS
GenReports4Batch.ps1 generates html ouput for reports on batch jobs

.DESCRIPTION
GenRapportsBatch.ps1 generates html ouput for reports on batch jobs

.Parameter oracleSid
oracleSid is used to setup Oracle environment variable ORACLE_SID.

.Parameter schema
schema : clv61xxx schema with which to run the reports

.Example 
  GenReports4Batch -oracleSid orlsol08 -schema clv61in1	-reportOut d:\solife-db\html
#>

[CmdletBinding()] param(
  [Parameter(Mandatory=$True) ] [string]$oracleSid,
  [Parameter(Mandatory=$True) ] [string]$schema,
  [Parameter(Mandatory=$True) ] [string]$dateParam,
  [string]$reportDir = 'd:\solife-db\html'
)

##########################################################################################################
function ListBatches {
  param ( $cnx, $schema, $reportOut, $dateParamSQL )

  $thisFunction = '{0}' -f $MyInvocation.MyCommand
  #write-output `n"This is function $thisFunction"
  #write-output "`List description for all batches"

  # 
  $sql = @"
set termout off
set echo off
set feedback off
alter session set current_schema=$schema
/
set feedback on
set pagesize 50
ttitle '$reportOut'
SELECT *
FROM (
select bj.job_id,
description,
case bj.batch_job_status_codeid
when 0 then 'PENDING'
when 2 then 'PREPRO'
when 3 then 'PROCESSING'
when 4 then 'POSTPRO'
when 5 then 'SEL_ERR'
when 6 then 'PREPRO_ERR'
when 7 then 'PRO_ERR'
when 8 then 'POSTPRO_ER'
when 9 then 'CANCELLED'
when 10 then 'COMPLETED'
when 11 then 'PAUSED'
when 12 then 'PAUSING'
when 13 then 'CANCELLING'
when 14 then 'ERROR'
when 15 then 'COMPLE_ERR'
else
'NA' end as status,
(bj.modification_date_time - bj.creation_date_time) as duration,
bj.creation_date_time,
--bj.modification_date_time,
bji.execution_count,
bji.error_count
from batch b
inner join batch_job bj on bj.BATCH_OID = b.oid
inner join batch_job_info bji on bj.info_oid = bji.oid
where description in( 'Processing of auto actions','Indexation Batch','Rescheduling batch','Coverage Charges Batch'
                     ,'Guaranteed rate reinvestment batch','Billing Reminder Batch','Financial operation batch','Generic fees'
                     ,'Financial Transfers Execution Batch','Benefit payment Batch','Payment instructions out batch','Regular Service Batch'
                     ,'Policy Notification Batch','Market order batch','Accounting transaction batch','Life certficate for annuities'
                     ,'claim review batch','Cooling Off Switch Batch','Term batch')
and bj.creation_date_time > to_date ('$dateParamSQL','DD/MM/YY') - 0.23 -- 0.23 = minus 5.5/24 => depuis 20h la veille
order by bj.job_id desc
)
--WHERE rownum <= 150
/
"@

  # Run sqlplus script
 $sql | sqlplus -S -MARKUP "HTML ON" $cnx

}
##########################################################################################################

##########################################################################################################
function Valuation {
  param ( $cnx, $schema, $reportOut, $dateParamSQL )

  $thisFunction = '{0}' -f $MyInvocation.MyCommand
  #write-output `n"This is function $thisFunction"
  #write-output "`List description for all batches"

  # Corruped blocks
  $sql = @"
set termout off
set echo off
set feedback off
alter session set current_schema=$schema
/
set feedback on
set pagesize 50
ttitle '$reportOut'
SELECT job_id,
         batch_name,
         starting_timestamp,
         end_timestamp,
         CAST (end_timestamp AS TIMESTAMP) - CAST (starting_timestamp AS TIMESTAMP) AS duration,
         execution_count,
         error_count,
         job_status,
         input_param_values.*,
         config_param_values.*
    FROM (
           SELECT batch_job.job_id,
                  batch_job_status.external_id AS job_status,
                  batch_type.external_id AS batch_name,
                  batch_job.starting_timestamp,
                  batch_job.end_timestamp,
                  batch_job.stack_trace,
                  batch_job_info.execution_count,
                  batch_job_info.error_count,
                  batch_job_configuration.sequence,
                  batch_job_configuration.parameter AS config_params,
                  batch_job_input.sequence,
                  batch_job_input.parameter AS input_params
             FROM batch_job
                  JOIN batch_job_info ON (batch_job_info.oid = batch_job.info_oid)
                  JOIN batch ON (batch.oid = batch_job.batch_oid)
                  JOIN batch_type ON (batch_type.codeid = batch.type_codeid)
                  JOIN batch_job_configuration ON (batch_job_configuration.batch_job_oid = batch_job.oid)
                  JOIN batch_job_input ON (batch_job_input.batch_job_oid = batch_job.oid)
                  JOIN batch_job_status ON (batch_job_status.codeid = batch_job.batch_job_status_codeid)
            WHERE batch_type.external_id IN ('VALUATION_BATCH', 'RCMP_SEC_VAL')
         ) batch_info,
         XMLTABLE (
           '/list'
           PASSING xmltype (input_params)
           COLUMNS "Configuration" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.parameter.InboundParameterImpl/name[.="Configuration"]/following-sibling::object',
                   "CalculationDate" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.parameter.InboundParameterImpl/name[.="CalculationDate"]/following-sibling::object',
                   "Policies" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.parameter.InboundParameterImpl/name[.="Policies"]/following-sibling::object',
                   "BackwardPeriod" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.parameter.InboundParameterImpl/name[.="BackwardPeriod"]/following-sibling::object',
                   "ValuationPeriodicity" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.parameter.InboundParameterImpl/name[.="ValuationPeriodicity"]/following-sibling::object',
                   "SkipMigratedPolicies" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.parameter.InboundParameterImpl/name[.="SkipMigratedPolicies"]/following-sibling::object')
         input_param_values,
         XMLTABLE (
           '/list'
           PASSING xmltype (config_params)
           COLUMNS "parallelProcessing" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.configuration.ConfigurationParameterImpl/name[.="parallelProcessing"]/following-sibling::o',
                   "parallelProcessors" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.configuration.ConfigurationParameterImpl/name[.="parallelProcessors"]/following-sibling::o',
                   "pageSize" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.configuration.ConfigurationParameterImpl/name[.="pageSize"]/following-sibling::o',
                   "cycleBound" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.configuration.ConfigurationParameterImpl/name[.="cycleBound"]/following-sibling::o',
                   "maxBusinessError" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.configuration.ConfigurationParameterImpl/name[.="maxBusinessError"]/following-sibling::o',
                   "maxError" VARCHAR2 (4000) PATH 'com.bsb.jf.batch.configuration.ConfigurationParameterImpl/name[.="maxError"]/following-sibling::o') config_param_values
   WHERE TRUNC (starting_timestamp) > SYSDATE - 1
ORDER BY job_id
/
"@

  # Run sqlplus script
 $sql | sqlplus -S -MARKUP "HTML ON" $cnx

}
##########################################################################################################

##########################################################################################################
function getReportName {
  param( $reportDir, $schema, $reportName, $timeStamp)
  $reportOut = $reportDir + '\' + $schema + '_' + $reportName + '_'  + $tstamp + '.html' 
  return $reportOut
}
##########################################################################################################

$thisScript = $MyInvocation.MyCommand
write-host "ThisScript is $thisScript"

$env:ORACLE_SID = $oracleSid
#Get-ChildItem Env:ORACLE_SID
write-host "schema is $schema"

# Check directory for reports exists
if ( ! (Test-Path $reportDir) ) {
  write-host "Please create directory $reportDir for reports"
  exit 1
}

$tstamp = get-date -Format 'yyyyMMddThhmmss'
#write-host "time is $tstamp"

# Connect as sys
$cnx = '/ as sysdba'

$reportOut = getReportName $reportDir $schema 'ListBatches' $tstamp 
write-host "$reportOut"
ListBatches $cnx $schema $reportOut $dateParam > $reportOut

$reportOut = getReportName $reportDir $schema 'Valuation' $tstamp 
write-host "$reportOut"
Valuation $cnx $schema $reportOut $dateParam > $reportOut

exit 0
