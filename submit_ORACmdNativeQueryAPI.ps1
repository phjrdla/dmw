# =======================================================
#
#    submit_ORACmdNativeQueryAPI.ps1
#             
# =======================================================
#
# NAME: submit_ORACmdNativeQueryAPI.ps1
# AUTHOR: TRICLIN J (Real)
# DATE: 15/01/2019
#
# ROLE: Execute ORACLE with API Oracle and generate csv out file
# VERSION: 1.0
# KEYWORDS:
# COMMENTS:  
#           
# =======================================================

# =======================================================
#    Bloc Declaration Arguments
# =======================================================
Param
(
        # Declaration de l'utilisateur ORACLE
        [Parameter(Mandatory=$true)][string]$ArgORAUser,

        # Declaration du password ORACLE
        [Parameter(Mandatory=$true)][string]$ArgORAPwd,

        # Declaration du serveur ORACLE (Declaration nom de domaine)
        [Parameter(Mandatory=$true)][string]$ArgORAServerDomaineName,

        # Declaration du port ORACLE
        [Parameter(Mandatory=$true)][string]$ArgORAPort,

        # Declaration du SID ORACLE
        [Parameter(Mandatory=$true)][string]$ArgORASID

)

# =======================================================
#    Bloc Declaration Arguments
# =======================================================
function FunctionConnexionDescriptionGenerator($ArgFunctORAUser, $ArgFunctORAPwd, $ArgFunctORAServerDomaineName, $ArgFunctORAPort, $ArgFunctORASID)
{
    
    $connexionParameterString = "User Id=${ArgFunctORAUser};Password=${ArgFunctORAPwd};Data Source=(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = ${ArgFunctORAServeurDomaineName})(PORT = ${ArgFunctORAPort})) (CONNECT_DATA = (SERVER = DEDICATED) (SID = ${ArgFunctORASID})))"

    return $connexionParameterString

}

# ======================================
#    Bloc du PROGRAMME MAIN
# ======================================

function main
{
    Param
    (
            # Declaration de l'utilisateur ORACLE
            [Parameter(Mandatory=$true)][string]$ArgORAUser,

            # Declaration du password ORACLE
            [Parameter(Mandatory=$true)][string]$ArgORAPwd,

            # Declaration du serveur ORACLE (Declaration nom de domaine)
            [Parameter(Mandatory=$true)][string]$ArgORAServerDomaineName,

            # Declaration du port ORACLE
            [Parameter(Mandatory=$true)][string]$ArgORAPort,

            # Declaration du SID ORACLE
            [Parameter(Mandatory=$true)][string]$ArgORASID

    )

    Write-Host "========================================="
    Write-Host "||                                     ||" 
    Write-Host "||                                     ||" 
    Write-Host "||          LANCEMENT SCRIPT           ||" 
    Write-Host "||    submit_ORACmdNativeQueryAPI.ps1  ||"
    Write-Host "||                                     ||" 
    Write-Host "||                                     ||"
    Write-Host "========================================="

    Write-Host ""
    Write-Host ""
    Write-Host "Recuperation et definition du parametrage en cours..."

    $ORAUser = $ArgORAUser
    $ORAPwd = $ArgORAPwd
    $ORAServerDomaineName = $ArgORAServerDomaineName
    $ORAPort = $ArgORAPort
    $ORASID = $ArgORASID

    $workingDirectory = $PSScriptRoot
	Write-Host "$workingDirectory "

    $ORAAPIFileName = "Oracle.ManagedDataAccess.dll"
    $ORAAPIFileFullPath = $workingDirectory + "\" + $ORAAPIFileName

    #function FunctionConnexionDescriptionGenerator($ArgORAUser, $ArgORAPwd, $ArgORAServerDomaineName, $ArgORAPort, $ArgORASID)
    $ORACLEDescriptionConnexion = FunctionConnexionDescriptionGenerator $ORAUser $ORAPwd $ORAServerDomaineName $ORAPort $ORASID

    Write-Host " =>Recuperation du parametrage OK"
    Write-Host ""

    Write-Host "Verification existence API Oracle en cours..."
    if(Test-Path $ORAAPIFileFullPath)
    {
        Write-Host " =>Le fichier existe OK"
    }
    else
    {
        Write-Host " =>Le fichier n'existe pas"
        Write-Host " =>Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    }
    Write-Host ""
    Write-Host ""

    Write-Host " Lancement de la requete - Rappel parametrage:"
    Write-Host "----------------------------------------------"
    Write-Host "ORACLE Serveur        : '${ORAServerDomaineName}'"
    Write-Host "ORACLE Port           : '${ORAPort}'"
    Write-Host "ORACLE SID            : '${ORASID}'"
    Write-Host "ORACLE User           : '${ORAUser}'"
    Write-Host "ORACLE API Connexion  : '${ORAAPIFileName}'"
    Write-Host ""
    Write-Host " Connexion à ORACLE -'${ORASID}'- en cours..."
    Write-Host ""

    Write-Host "Ajout de l'API pour connexion à ORACLE en cours..."
    Add-Type -Path $ORAAPIFileFullPath

    if($?)
    {
        Write-Host " =>Ajout Librairies OK"
    }
    else
    {
        Write-Host " =>Echec ajout librairies -KOKOKO"
        Write-Host " =>Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    }
    Write-Host ""
    Write-Host ""

    $connexionOracle = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($ORACLEDescriptionConnexion)
    
    $connexionOracle.open()
    $connexionOracle.State
    $connexionOracle.Close()
    $connexionOracle.State

}


# ======================================
#    Execution du PROGRAMME
# ======================================

#    Arg1:user ORACLE, Arg2:pwd ORACLE, Arg3:serveur ORACLE, Arg4:Port ORACLE, Arg5: SID ORACLE
main $ArgORAUser $ArgORAPwd $ArgORAServerDomaineName $ArgORAPort $ArgORASID