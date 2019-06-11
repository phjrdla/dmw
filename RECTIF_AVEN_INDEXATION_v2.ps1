# =======================================================
#
#             RECTIF_AVEN_INDEXATION_v2.ps1
#             
# =======================================================
#
# NAME: RECTIF_AVEN_INDEXATION_v2.ps1
#
# ROLE: 
# To be run on ORLSOL00  ora12prdbak
# runs Solife ODS Prod data fixing script RECTIF_AVEN_INDEXATION.sql
# a schema change is done to solife_it0_ods after connecting to clv61prd
#
# CREATOR: P BRIENS 01/02/2019
# UPDATE : JT - 13/02/2019
# VERSION: 2.0
# KEYWORDS:
# COMMENTS:  
#           
# =======================================================

# =======================================================
#    Bloc Declaration Arguments
# =======================================================
Param
(
        # Declaration du connecteur
        [Parameter(Mandatory=$true)][string]$argConnectStr,

        # Declaration du schema
        [Parameter(Mandatory=$true)][string]$argSchema,

        # Declaration schema
        [Parameter(Mandatory=$true)][string]$argPass

)
#Parametres Natifs                     -conn orlsol00      -schema clv61prd   -pass CLV_61_PRD                       
D:\SOLIFE-DB\scripts\ExecSqlStmtV3.ps1 -conn $argConnectStr -schema $argSchema -pass $argPass -stmtfile D:\SOLIFE-DB\scripts\RECTIF_AVEN_INDEXATION.sql -StmtOut c:\temp\RECTIF_AVEN_INDEXATION.out -mode true

GET-content c:\temp\RECTIF_AVEN_INDEXATION.out


Write-Host ""
Write-Host "------------------------------"
Write-Host " TRT TERMINE AVEC SUCCES -OK  "
Write-Host "------------------------------"
Write-Host "Exit 0"

Exit 0