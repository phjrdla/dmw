SET ECHO ON
SET TIMING ON
SET VERIFY ON
WHENEVER SQLERROR EXIT FAILURE

COLUMN OID NEW_VALUE pcrv_oid

SELECT TO_CHAR (oid) AS oid
  FROM policy_valuation_configuration
 WHERE policy_valuation_configuration.identifier = 'PolicyCoverageReserveValuation';


-- ------------------------------------------------------------------------------------------------------

ALTER SESSION ENABLE PARALLEL DML;

DELETE /*+ parallel */
       FROM policy_valuation
      WHERE policy_valuation.valuation_date = DATE '2018-12-31' AND policy_valuation.configuration_oid IN (&&pcrv_oid);

COMMIT;

-- ------------------

DELETE /*+ parallel */
       FROM policy_valuation_specif_rules
      WHERE NOT EXISTS
              (SELECT 1
                 FROM policy_valuation
                WHERE policy_valuation.oid = policy_valuation_specif_rules.policy_valuation_oid);

COMMIT;

