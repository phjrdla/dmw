set term off    
set echo off    
set underline off    
set colsep ';'    
set linesize 32767    
set pages 0
set trimspool on    
set trimout on    
set feedback off    
set heading on    
set newpage 0    
set headsep off    
;set wrap off    
set termout off    
set long 20000    

spool fin_inst_op_data_02.csv
SELECT fin_inst_op_data.*, (fin_inst_op_data.accupcbefore + fin_inst_op_data.accupcmoved) AS ccupcafter
from (SELECT financial_operation.policy_number,
               financial_operation.external_id,
               identifier.identifier as fund_identifier,
               guaranteed_rate.identifier as gr_identifier,
                                               currency.iso_code,
               fin_inst_financial_operation.fund_direction,
               NVL (allocatedamounts.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1), 0)
                 AS allocatedamount,
               cap_prices_and_quantities.quantity_or_amount * ROUND (cap_prices_and_quantities.price, 2) * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1)
                 AS capitalamount,
               cap_prices_and_quantities.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1)
                 AS capumoved,
               cap_prices_and_quantities.price
                 AS capprice,
               CASE WHEN (financial_operation.migrated = 1 AND financial_operation.sync_id IS NULL) THEN accupcmovedsandprices.price ELSE baresprices.price END
                 AS bareprice,
               accumoveds.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1)
                 AS accumoved,
               accumoveds.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1)
                 AS accuafter,
               cap_prices_and_quantities.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1)
                 AS capuafter,
               NVL (accupcmovedsandprices.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1), 0)
                 AS accupcmoved,
               NVL (NVL (allocatedamounts.quantity_or_amount, NVL (estimatedallocatedamounts.quantity_or_amount, estimatedallocatedamountsprep.quantity_or_amount)), 0)
                 AS estimatedallocatedamount,
               ot.external_id
                 AS operation_type,
               --fundnetamounts.quantity_or_amount       AS quantity_or_amount1,
               --netamounts.quantity_or_amount       AS quantity_or_amount2,
               --roundings.quantity_or_amount       AS quantity_or_amount3,
               --allocatedamounts.quantity_or_amount  AS quantity_or_amount4,
               (CASE
                  WHEN ot.external_id NOT IN ('COMP',
                                              'SWITCH_CO',
                                              'SWITCH',
                                              'CORP_ACT',
                                              'FUND_REINV') THEN
                    (CASE
                       WHEN (fundnetamounts.quantity_or_amount IS NULL AND netamounts.quantity_or_amount IS NULL) THEN NULL
                       ELSE NVL (NVL (fundnetamounts.quantity_or_amount, netamounts.quantity_or_amount), 0)
                     END)
                  ELSE
                    (CASE
                       WHEN (roundings.quantity_or_amount IS NULL AND allocatedamounts.quantity_or_amount IS NULL) THEN
                         NULL
                       ELSE
                           (NVL (allocatedamounts.quantity_or_amount, 0) - NVL (roundings.quantity_or_amount, 0))
                         * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1)
                     END)
                END)
                 AS netamount,
               accupcmovedsandprices.price
                 AS accprice,
               (CASE
                  WHEN (    EXISTS
                              (SELECT 1
                                 FROM guaranteed_rate
                                WHERE fin_inst_financial_operation.financial_instrument_oid = guaranteed_rate.oid)
                        AND fin_inst_financial_operation.pc_units_without_interest IS NOT NULL
                        AND (allocatedamounts.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1) * (-1) >
                             fin_inst_financial_operation.pc_units_without_interest)
                        AND (allocatedamounts.quantity_or_amount * DECODE (fin_inst_financial_operation.fund_direction, 1, 1, -1) < fin_inst_financial_operation.acc_pc_units)) THEN
                    fin_inst_financial_operation.acc_pc_units
                  WHEN (    EXISTS
                              (SELECT 1
                                 FROM guaranteed_rate
                                WHERE fin_inst_financial_operation.financial_instrument_oid = guaranteed_rate.oid)
                        AND fin_inst_financial_operation.pc_units_without_interest IS NOT NULL) THEN
                    fin_inst_financial_operation.pc_units_without_interest
                  ELSE
                    fin_inst_financial_operation.acc_pc_units
                END)
                 AS accupcbefore,
               fin_inst_financial_operation.price_date,
               --''                                   AS isfullredemption,
               fin_inst_financial_operation.acc_pc_units,
               fin_inst_financial_operation.current_split,
               fin_inst_financial_operation.amount,
               fin_inst_financial_operation.units,
               financial_operation.creation_date_time
                 AS finop_creation_date_time
          FROM financial_operation
               JOIN fin_inst_financial_operation ON (financial_operation.oid = fin_inst_financial_operation.financial_operation_oid 
                                                                                                       and financial_operation.creation_date_time > to_date('30/06/2018 09:55:00', 'dd/mm/yyyy HH24:MI:SS')
                                                                                                       and financial_operation.creation_date_time < to_date('30/06/2018 13:08:00', 'dd/mm/yyyy HH24:MI:SS')
                                                                                                       )
               JOIN operation_type ot ON (financial_operation.operation_type_oid = ot.oid and  ot.external_id = 'FEE_AMOUNT')
                                               join securities securities on securities.oid = fin_inst_financial_operation.financial_instrument_oid
                                               join currency currency on currency.oid = securities.issue_currency_oid
                                               left outer join identifier identifier on (securities.oid = identifier.securities_oid and identifier.nature = 32)
                                               left outer join guaranteed_rate guaranteed_rate on guaranteed_rate.oid = securities.oid
               --allocated amounts
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid AS fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.applied_rate,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 144
                               ) --(amount_type=144 : FUND_ALLOCATED_AMOUNT)
                                 allocatedamounts
                 ON financial_operation.oid = allocatedamounts.oid AND fin_inst_financial_operation.oid = allocatedamounts.fifo_oid
               --
               --cap prices and quantities
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid AS fifo_oid,
                                        client_instruction.price,
                                        elementary_operation_detail.quantity_or_amount,
                                        client_instruction.creation_date_time,
                                        client_instruction.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 20 --(amount_type=20 : UNITS)
                                                                                            AND elementary_operation_detail.sub_amount_type_codeid = 143
                               ) cap_prices_and_quantities --(amount_type=143 : CAP_UNITS)
                 ON financial_operation.oid = cap_prices_and_quantities.oid AND fin_inst_financial_operation.oid = cap_prices_and_quantities.fifo_oid
               --bares prices
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid AS fifo_oid,
                                        securities_quotation.price,
                                        securities_quotation.creation_date_time,
                                        securities_quotation.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN securities_quotation
                                          ON     fin_inst_financial_operation.financial_instrument_oid = securities_quotation.securities_oid
                                             AND securities_quotation.type_of_quotation = 1 --(1: BARE)
                                             AND securities_quotation.type_of_valuation_codeid = 0 --(0: OFFICIAL)
                                             AND securities_quotation.status_codeid = 1 --(1: VALIDATED)
                                             AND securities_quotation.price_date =
                                                 (SELECT MAX (lastpricedate_secu_quotation.price_date)
                                                    FROM securities_quotation lastpricedate_secu_quotation
                                                   WHERE     lastpricedate_secu_quotation.type_of_quotation = 1
                                                         AND lastpricedate_secu_quotation.type_of_valuation_codeid = 0
                                                         AND lastpricedate_secu_quotation.status_codeid = 1
                                                         AND lastpricedate_secu_quotation.price_date <= NVL (fin_inst_financial_operation.price_date, SYSDATE)
                                                         AND fin_inst_financial_operation.financial_instrument_oid = lastpricedate_secu_quotation.securities_oid)
                               ) baresprices
                 ON financial_operation.oid = baresprices.oid AND fin_inst_financial_operation.oid = baresprices.fifo_oid
               --accumoveds
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 20 --(amount_type=20 : ACC_UNITS)
                                                                                            AND elementary_operation_detail.sub_amount_type_codeid = 138
                               ) accumoveds --(amount_type=138 : UNITS)
                 ON financial_operation.oid = accumoveds.oid AND fin_inst_financial_operation.oid = accumoveds.fifo_oid
               --accupcmovedsandprices
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.promotional_offer_identifier,
                                        elementary_operation_detail.promotional_offer_boosted_rate,
                                        client_instruction.price,
                                        client_instruction.creation_date_time,
                                        client_instruction.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 20 --(amount_type=20 : UNITS)
                                                                                            AND elementary_operation_detail.sub_amount_type_codeid = 142
                               ) accupcmovedsandprices --(amount_type=142 : ACC_PC_UNITS)
                 ON financial_operation.oid = accupcmovedsandprices.oid AND fin_inst_financial_operation.oid = accupcmovedsandprices.fifo_oid
               --estimated fund allocated amounts (ESTIMATED_FUND_ALLOCATED_AMOUNT)
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 444
                               ) --(amount_type=444 : ESTIMATED_FUND_ALLOCATED_AMOUNT)
                                 estimatedallocatedamounts
                 ON financial_operation.oid = estimatedallocatedamounts.oid AND fin_inst_financial_operation.oid = estimatedallocatedamounts.fifo_oid
               --estimated fund allocated amount (ESTIMATED_FUND_ALLOCATED_AMOUNT_PREPARE)
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 473
                               ) --(amount_type=473 : ESTIMATED_FUND_ALLOCATED_AMOUNT_PREPARE)
                                 estimatedallocatedamountsprep
                 ON financial_operation.oid = estimatedallocatedamountsprep.oid AND fin_inst_financial_operation.oid = estimatedallocatedamountsprep.fifo_oid
               --netamounts (FUND_NET_AMOUNT)
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 468
                               ) --(amount_type=468 : FUND_NET_AMOUNT)
                                 fundnetamounts
                 ON financial_operation.oid = fundnetamounts.oid AND fin_inst_financial_operation.oid = fundnetamounts.fifo_oid
               --netamounts
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 148
                               ) --(amount_type=148 : NET_AMOUNT)
                                 netamounts
                 ON financial_operation.oid = netamounts.oid AND fin_inst_financial_operation.oid = netamounts.fifo_oid
                              --financial instrument fees
               LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 518
                               ) --(amount_type=518 : TOTAL_FININST_FEES)
                                 fininstrumentfees
                 ON financial_operation.oid = fininstrumentfees.oid AND fin_inst_financial_operation.oid = fininstrumentfees.fifo_oid
               --roundings
              LEFT OUTER JOIN (
                                 SELECT financial_operation.oid,
                                        fin_inst_financial_operation.oid fifo_oid,
                                        elementary_operation_detail.quantity_or_amount,
                                        elementary_operation_detail.creation_date_time,
                                        elementary_operation_detail.modification_date_time
                                   FROM financial_operation
                                        JOIN fin_inst_financial_operation ON financial_operation.oid = fin_inst_financial_operation.financial_operation_oid
                                        JOIN client_instruction ON fin_inst_financial_operation.instruction_oid = client_instruction.oid
                                        JOIN elementary_operation_detail ON elementary_operation_detail.elementary_operation_oid = client_instruction.oid
                                  WHERE elementary_operation_detail.amount_type_codeid = 155 --(amount_type=155 : FUND_CHARGES)
                                                                                             AND elementary_operation_detail.sub_amount_type_codeid = 149
                               ) roundings --(amount_type=149 : ROUNDING_DIFFERENCE)
                 ON financial_operation.oid = roundings.oid AND fin_inst_financial_operation.oid = roundings.fifo_oid--accprices 
) fin_inst_op_data
/
spool off
                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                                             
 
 