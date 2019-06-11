SET ECHO ON
SET TIMING ON
SET VERIFY ON
WHENEVER SQLERROR EXIT FAILURE

COLUMN OID NEW_VALUE pcrv_oid

SELECT TO_CHAR (oid) AS oid
  FROM policy_valuation_configuration
 WHERE policy_valuation_configuration.identifier = 'PolicyCoverageReserveValuation';

COLUMN OID NEW_VALUE pdfib_oid

SELECT TO_CHAR (oid) AS oid
  FROM policy_valuation_configuration
 WHERE policy_valuation_configuration.identifier = 'PolicyDailyFinInstBalance';

-- ------------------------------------------------------------------------------------------------------

ALTER SESSION ENABLE PARALLEL DML;

DELETE /*+ parallel */
       FROM policy_valuation
      WHERE policy_valuation.valuation_date = DATE '2018-12-31' AND policy_valuation.configuration_oid IN (&&pcrv_oid, &&pdfib_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_inv_values
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_inv_values.policy_valuation_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_fininst_dtl
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_inv_values
                WHERE policy_valuation_inv_values.oid = policy_valuation_fininst_dtl.pol_val_inv_values_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_fi_acc_dtl
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_fininst_dtl
                WHERE policy_valuation_fininst_dtl.oid = policy_valuation_fi_acc_dtl.policy_valuation_fininst_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_gr_acl_dtl
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_fininst_dtl
                WHERE policy_valuation_fininst_dtl.oid = policy_valuation_gr_acl_dtl.policy_valuation_fininst_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_val_by_slice
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_inv_values
                WHERE policy_valuation_inv_values.oid = policy_valuation_val_by_slice.pol_val_inv_values_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_flow_by_slice
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_inv_values
                WHERE policy_valuation_inv_values.oid = policy_valuation_flow_by_slice.pol_val_inv_values_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_risk_capital
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_risk_capital.policy_valuation_oid);
                
COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_other_value
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_risk_capital
                WHERE policy_valuation_risk_capital.oid = policy_valuation_other_value.policy_val_risk_capital_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_pricing_flow
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_risk_capital
                WHERE policy_valuation_risk_capital.oid = policy_valuation_pricing_flow.policy_val_risk_capital_oid);

COMMIT;

DELETE /*+ parallel */
       FROM policy_valuation_pricing_risk
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation_risk_capital
                WHERE policy_valuation_risk_capital.oid = policy_valuation_pricing_risk.policy_val_risk_capital_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_policy_loan
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_policy_loan.policy_valuation_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_risk_premium
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_risk_premium.policy_valuation_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_specif_rules
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_specif_rules.policy_valuation_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_sum_at_risk
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_sum_at_risk.policy_valuation_oid);

COMMIT;

