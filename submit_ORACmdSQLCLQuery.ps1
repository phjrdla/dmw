# =======================================================
#
#    submit_ORACMDSQLCLQuery.ps1
#             
# =======================================================
#
# NAME: submit_ORACMDSQLCLQuery.ps1
# AUTHOR: TRICLIN J (Real)
# DATE: 15/04/2019
#
# ROLE: Execute ORACLE with SQLCL Query and generate ORA out file
# VERSION: 1.0
# KEYWORDS:
# COMMENTS:  
#           
# =======================================================

# =======================================================
#    Bloc Declaration ORA
# =======================================================
Param
(
        # Declaration du serveur ORA
        [Parameter(Mandatory=$true)][string]$argORAServeurAndPort,

        # Declaration de la DB
        [Parameter(Mandatory=$true)][string]$argORADB,

        # Declaration ORA Query
        [Parameter(Mandatory=$true)][string]$argORAQueryBaseFilePath,

        # Declaration ORA User
        [Parameter(Mandatory=$true)][string]$argORAProtectedUser,

        # Declaration ORA Pwd
        [Parameter(Mandatory=$true)][string]$argORAProtectedPwd,

        # Declaration chemin de sortie ORA
        [Parameter(Mandatory=$true)][string]$argORAOutFilePath,

        # Declaration du nom du rapport
        [Parameter(Mandatory=$true)][string]$argORAReportFileName,

        # Declaration Extension File
        [Parameter(Mandatory=$true)][string]$argORAColSeparator,

        # Declaration parametre SQLCL 1
        [Parameter(Mandatory=$false)][string]$argORAParameter1 = "",

        # Declaration parametre SQLCL 2
        [Parameter(Mandatory=$false)][string]$argORAParameter2 = "",

        # Declaration parametre SQLCL 3
        [Parameter(Mandatory=$false)][string]$argORAParameter3 = "",

        # Declaration force encodage standard de sortie fichiers
        [Parameter(Mandatory=$false)][string]$argForceEncodingOutFileParam = ""
)

# =======================================================
#    Bloc Fonctions
# =======================================================

function TimeStampFunction
{

    #[DateTime]$getDate = (Get-Date -Format "yyyy/MM/dd HH:mm:ss.fff")
    [DateTime]$getDate = Get-Date

    #le format du string attend un int pour l'option 'f'
    #[string]$varTS = "{0:D4}" -f [int]"string"
    # ou [string]$varTS = "{0:D4}" -f int/digit
    [string]$yearTS = "{0:D4}" -f $($getDate.Year)
    [string]$monthTS = "{0:D2}" -f $($getDate.Month)
    [string]$dayTS = "{0:D2}" -f $($getDate.Day)

    #return "YYYYMMDD"
    return "${yearTS}${monthTS}${dayTS}"
} 

# ======================================
#    Bloc du PROGRAMME MAIN
# ======================================

function main
{
    Param
    (
         # Declaration du serveur ORA
        [Parameter(Mandatory=$true)][string]$argORAServeurAndPort,

        # Declaration de la DB
        [Parameter(Mandatory=$true)][string]$argORADB,

        # Declaration ORA Query
        [Parameter(Mandatory=$true)][string]$argORAQueryBaseFilePath,

        # Declaration ORA User
        [Parameter(Mandatory=$true)][string]$argORAProtectedUser,

        # Declaration ORA Pwd
        [Parameter(Mandatory=$true)][string]$argORAProtectedPwd,

        # Declaration chemin de sortie ORA
        [Parameter(Mandatory=$true)][string]$argORAOutFilePath,

        # Declaration du nom du rapport
        [Parameter(Mandatory=$true)][string]$argORAReportFileName,

        # Declaration Extension File
        [Parameter(Mandatory=$true)][string]$argORAColSeparator,

        # Declaration parametre SQLCL 1
        [Parameter(Mandatory=$false)][string]$argORAParameter1 = "",

        # Declaration parametre SQLCL 2
        [Parameter(Mandatory=$false)][string]$argORAParameter2 = "",

        # Declaration parametre SQLCL 3
        [Parameter(Mandatory=$false)][string]$argORAParameter3 = "",

        # Declaration force encodage standard de sortie fichiers
        [Parameter(Mandatory=$false)][string]$argForceEncodingOutFileParam = ""
    )

    Write-Host "==========================================="
    Write-Host "||                                       ||" 
    Write-Host "||                                       ||" 
    Write-Host "||          LANCEMENT SCRIPT             ||" 
    Write-Host "||       submit_ORACMDSQLCLQuery.ps1     ||"
    Write-Host "||                                       ||" 
    Write-Host "||                                       ||"
    Write-Host "==========================================="

    Write-Host ""
    Write-Host ""
    Write-Host " Recuperation et definition du parametrage en cours..."

    $ORAServeurAndPort = $argORAServeurAndPort
    $ORADB = $argORADB
    $ORAQueryBaseFilePath = $argORAQueryBaseFilePath
    $ORAQueryDefinedFilePath = ""
    $ORAFileFamily = ""

    $ORAProtectedUserFilePath = $argORAProtectedUserFilePath

    $ORAProtectedUser = $argORAProtectedUser 
    $ORAProtectedPwd = $argORAProtectedPwd

    $ORAOutFilePath = $argORAOutFilePath
    $ORAReportFileName = $argORAReportFileName
    $ORAColSeparator = $argORAColSeparator
    $ORAFileExtension = ""

    if($argORAQueryParams.Length -eq 0)
    {
        $ORAQueryParams = ""
    }
    else
    {
        $ORAQueryParams = $argORAQueryParams
    }

    if($argForceEncodingOutFileParam.Length -eq 0)
    {
        $forceEncodingOutFileParam = ""
    }
    else
    {
        $forceEncodingOutFileParam = $argForceEncodingOutFileParam
    }

    $SQLCLCMDFullPathList = @("D:\Oracle\tools\sqlcl\bin\sql.exe")
    $ORASQLCLCMDFullPathOK = ""

    Write-Host " =>Fin de recuperation du parametrage OK"

    
    Write-Host ""
    Write-Host " Verifcation existence commande SQLcl.exe en cours..."
    

    $flagORASQLCLCMDexists = 0

    Foreach($ORASQLCLCMD in $SQLCLCMDFullPathList)
    {
        Write-Host "$ORASQLCLCMD"

        if(Test-Path ($ORASQLCLCMD))
        {
            $ORASQLCLCMDFullPathOK = $ORASQLCLCMD
            $flagORASQLCLCMDexists = 1
            break
        }
    
    }

    if($flagORASQLCLCMDexists -eq 1)
    {
        Write-Host " =>SQL.exe (SQLCL) trouve: ${ORASQLCLCMDFullPathOK}"
    }
    else
    {
        Write-Host " =>Aucun SQL.exe (SQLCL) sur la machine"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    }

    Write-Host " Verification de l'existence du separateur de colonnes en cours..."

    if($ORAColSeparator.Length -gt 0 )
    {
        Write-Host " =>Separarteur trouve: '$ORAColSeparator'"

        switch($ORAColSeparator)
        {
            ","{
                Write-Host " =>Generation d'un fichier CSV"
                $ORAFileExtension=".csv"
                $ORAFileFamily = "_CSV"
                $ORAQueryDefinedFilePath = $ORAQueryBaseFilePath + $ORAFileFamily + ".sql"
            }
            ";"{
                Write-Host " =>Generation d'un fichier DSV"
                $ORAFileExtension=".dsv"
                $ORAFileFamily = "_DSV"
                $ORAQueryDefinedFilePath = $ORAQueryBaseFilePath + $ORAFileFamily + ".sql"
            
            }
            default{$ORAFileExtension=".csv"; $ORAColSeparator="," 
                    $ORAFileFamily = "_CSV"
                    $ORAQueryDefinedFilePath = $ORAQueryBaseFilePath + $ORAFileFamily + ".sql"
            }
        }

    }else
    {
        Write-Host " =>Aucun separateur defini"
        Write-Host " =>Analyser Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    }


    Write-Host ""
    Write-Host " Verification de l'existence de la requete '${ORAQueryDefinedFilePath}' en cours..."
    if(-not (Test-Path $ORAQueryDefinedFilePath))
    {
        Write-Host " =>Fichier Requete SQL inexistant"
        Write-Host " =>Analyser Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    
    }
    else
    {
        Write-Host " =>Fichier Requete SQL trouve -OK"

    }

    Write-Host ""
    Write-Host " Verification du repertoire de sortie '$ORAOutFilePath' en cours..."

    if(-not (Test-Path $ORAOutFilePath))
    {
        Write-Host " =>Le repertoire n'existe pas"
        Write-Host " =>Analyser Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    
    }
    else
    {
        Write-Host " =>Le repertoire existe -OK"
    }

    Write-Host ""
    Write-Host " Verification coherence du nom du rapport en cours..."

    if($ORAReportFileName.Length -eq 0)
    {
        Write-Host " =>Aucun nom de rapport defini"
        Write-Host " =>Analyser Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    }
    else
    {
        Write-Host " =>Nom du rapport OK"
    }
    Write-Host ""
    Write-Host ""

    $ORAOutFileNameFullPath = $ORAOutFilePath + "\" + $ORAReportFileName + "_$(TimeStampFunction)" + $ORAFileExtension

    Write-Host " Lancement de la requete - Rappel parametrage:"
    Write-Host "----------------------------------------------"
    Write-Host "ORACLE Serveur:Port   : '${ORAServeurAndPort}'"
    Write-Host "ORACLE DB             : '${ORADB}'"
    Write-Host "ORACLE User           : '${ORAProtectedUser}'"
    Write-Host "ORACLE Query File     : '${ORAQueryDefinedFilePath}'"
    Write-Host "SQL.exe FullPath      : '${ORASQLCLCMDFullPathOK}'"
    Write-Host "ORACLE Scripts Params : $argORAParameter1 $argORAParameter2 $argORAParameter3"
    Write-Host ""
    Write-Host " Lancement requete SQL en cours..."
    Write-Host "=> ${ORASQLCLCMDFullPathOK} '${ORAProtectedUser}/ORAProtectedPwd@//${ORAServeurAndPort}/${ORADB}' @$ORAQueryDefinedFilePath ""$ORAOutFileNameFullPath"" ""$ORAColSeparator"" ""$argORAParameter1"" ""$argORAParameter2"" ""$argORAParameter3"""
    Write-Host ""

    &$ORASQLCLCMDFullPathOK "${ORAProtectedUser}/${argORAProtectedPwd}@//${ORAServeurAndPort}/${ORADB}" @$ORAQueryDefinedFilePath "$ORAOutFileNameFullPath" "$ORAColSeparator" "$argORAParameter1" "$argORAParameter2" "$argORAParameter3" | Out-Null

    if($?)
    {
        Write-Host " =>Recuperation Data et Generation du fichier OK"

    }
    else
    {
        Write-Host " =>Erreur durant la generation"
        Write-Host " =>Analyser Erreur"
        Write-Host ""
        Write-Host "--------------------------------"
        Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
        Write-Host "--------------------------------"

        Exit 1
    }

    Write-Host ""
    Write-Host ""
    Write-Host "-------------------------------------------------------"
    Write-Host " DEFINITION FORMAT FICHIER  / CONVERSION CARACTERES    "
    Write-Host "-------------------------------------------------------"
    Write-Host ""
    Write-Host ""
    if($forceEncodingOutFileParam.Length -eq 0)
    {
        Write-Host " =>Aucune conversion post generation determinee -OK"
    }
    else
    { 
        
        switch($forceEncodingOutFileParam)
        {
            "ASCII"{

                $ORAOutConvertedFileNameFullPath = $ORAOutFilePath + "\" + $ORAReportFileName + "_$(TimeStampFunction)"+ "_${forceEncodingOutFileParam}" + $ORAFileExtension

                Write-Host " =>Conversion vers 'ASCII' detectee -OK"
                Write-Host "Lancement de la conversion en cours..."

                #Get-Content $ORAOutFileNameFullPath -Raw -Encoding Oem | Out-File $ORAOutConvertedFileNameFullPath -Append -Encoding ASCII
                Get-Content $ORAOutFileNameFullPath | %{

                    $_.Replace("�","�").Replace("é","�").Replace("É","�").Replace("��","�").Replace("�","�").Replace("è","�").Replace("È","�").Replace("��","�").Replace("ê","�").Replace("�","�").Replace("Ê","�").Replace("��","�").Replace("�","�").Replace("ë","�").Replace("Ë","�").Replace("�","�").Replace("ã","�").Replace("�","�").Replace("��","�").Replace("À","�").Replace("�","�").Replace("ä","�").Replace('��',"�").Replace('Ä',"�").Replace("�","�").Replace("ç","�").Replace("��","�").Replace("Ç","�").Replace("�","�").Replace("ï","�").Replace("�?","�").Replace("�?","�").Replace("�","�").Replace("î","�").Replace("��","�").Replace("Î","�").Replace("�","�").Replace("û","�").Replace("��","�").Replace("Û","�").Replace("�","�").Replace("ù","�").Replace("��","�").Replace("Ù","�").Replace("�","�").Replace("ü","�").Replace("��","�").Replace("Ü","�").Replace("�","�").Replace("ô","�").Replace('��',"�").Replace('Ô',"�").Replace("�","�").Replace("ö","�").Replace("��","�").Replace("Ö","�").Replace("��","�").Replace("ß","�").Replace("�","�").Replace("ñ","�").Replace("��","�").Replace("Ñ","�").Replace("�","�").Replace("â","�").Replace("��","�").Replace("Â�","�") `
                    | Out-File $ORAOutConvertedFileNameFullPath -Encoding ascii -Append

                }

                if($?)
                {
                    Write-Host " =>Conversion terminee OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant la conversion"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }

                Write-Host ""
                Write-Host "Suppression du fichier originel '${ORAOutFileNameFullPath}' en cours..."
                Remove-Item $ORAOutFileNameFullPath -Force

                if($?)
                {
                    Write-Host " =>Suppression OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant la suppression"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }

                Write-Host ""
                Write-Host "Renommage fichier converti '$ORAOutConvertedFileNameFullPath' en '${ORAOutFileNameFullPath}' en cours..."
                Move-Item -Path $ORAOutConvertedFileNameFullPath -Destination $ORAOutFileNameFullPath

                if($?)
                {
                    Write-Host " =>Renommage OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant le renommage -KOKOKO"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }



            }

            "UTF8"{

                $ORAOutConvertedFileNameFullPath = $ORAOutFilePath + "\" + $ORAReportFileName + "_$(TimeStampFunction)"+ "_${forceEncodingOutFileParam}" + $ORAFileExtension

                Write-Host " =>Conversion vers 'UTF8' detectee -OK"
                Write-Host "Lancement de la conversion en cours..."

                #Get-Content $ORAOutFileNameFullPath -Raw -Encoding Oem | Out-File $ORAOutConvertedFileNameFullPath -Append -Encoding UTF8
                Get-Content $ORAOutFileNameFullPath | %{

                    $_.Replace("�","�").Replace("é","�").Replace("É","�").Replace("��","�").Replace("�","�").Replace("è","�").Replace("È","�").Replace("��","�").Replace("ê","�").Replace("�","�").Replace("Ê","�").Replace("��","�").Replace("�","�").Replace("ë","�").Replace("Ë","�").Replace("�","�").Replace("ã","�").Replace("�","�").Replace("��","�").Replace("À","�").Replace("�","�").Replace("ä","�").Replace('��',"�").Replace('Ä',"�").Replace("�","�").Replace("ç","�").Replace("��","�").Replace("Ç","�").Replace("�","�").Replace("ï","�").Replace("�?","�").Replace("�?","�").Replace("�","�").Replace("î","�").Replace("��","�").Replace("Î","�").Replace("�","�").Replace("û","�").Replace("��","�").Replace("Û","�").Replace("�","�").Replace("ù","�").Replace("��","�").Replace("Ù","�").Replace("�","�").Replace("ü","�").Replace("��","�").Replace("Ü","�").Replace("�","�").Replace("ô","�").Replace('��',"�").Replace('Ô',"�").Replace("�","�").Replace("ö","�").Replace("��","�").Replace("Ö","�").Replace("��","�").Replace("ß","�").Replace("�","�").Replace("ñ","�").Replace("��","�").Replace("Ñ","�").Replace("�","�").Replace("â","�").Replace("��","�").Replace("Â�","�") `
                    | Out-File $ORAOutConvertedFileNameFullPath -Encoding utf8 -Append
                
                }

                if($?)
                {
                    Write-Host " =>Conversion terminee OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant la conversion"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }

                Start-Sleep -Seconds 1

                Write-Host ""
                Write-Host "Suppression du fichier originel '${ORAOutFileNameFullPath}' en cours..."
                Remove-Item $ORAOutFileNameFullPath -Force

                if($?)
                {
                    Write-Host " =>Suppression OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant la suppression"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }

                Write-Host ""
                Write-Host "Renommage fichier converti '$ORAOutConvertedFileNameFullPath' en '${ORAOutFileNameFullPath}' en cours..."
                Move-Item -Path $ORAOutConvertedFileNameFullPath -Destination $ORAOutFileNameFullPath

                if($?)
                {
                    Write-Host " =>Renommage OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant le renommage -KOKOKO"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }


            
            }

            "UTF32"{

                $ORAOutConvertedFileNameFullPath = $ORAOutFilePath + "\" + $ORAReportFileName + "_$(TimeStampFunction)"+ "_${forceEncodingOutFileParam}" + $ORAFileExtension

                Write-Host " =>Conversion vers 'UTF32' detectee -OK"
                Write-Host "Lancement de la conversion en cours..."

                                #Get-Content $ORAOutFileNameFullPath -Raw -Encoding Oem | Out-File $ORAOutConvertedFileNameFullPath -Append -Encoding UTF32
                Get-Content $ORAOutFileNameFullPath | %{

                    $_.Replace("�","�").Replace("é","�").Replace("É","�").Replace("��","�").Replace("�","�").Replace("è","�").Replace("È","�").Replace("��","�").Replace("ê","�").Replace("�","�").Replace("Ê","�").Replace("��","�").Replace("�","�").Replace("ë","�").Replace("Ë","�").Replace("�","�").Replace("ã","�").Replace("�","�").Replace("��","�").Replace("À","�").Replace("�","�").Replace("ä","�").Replace('��',"�").Replace('Ä',"�").Replace("�","�").Replace("ç","�").Replace("��","�").Replace("Ç","�").Replace("�","�").Replace("ï","�").Replace("�?","�").Replace("�?","�").Replace("�","�").Replace("î","�").Replace("��","�").Replace("Î","�").Replace("�","�").Replace("û","�").Replace("��","�").Replace("Û","�").Replace("�","�").Replace("ù","�").Replace("��","�").Replace("Ù","�").Replace("�","�").Replace("ü","�").Replace("��","�").Replace("Ü","�").Replace("�","�").Replace("ô","�").Replace('��',"�").Replace('Ô',"�").Replace("�","�").Replace("ö","�").Replace("��","�").Replace("Ö","�").Replace("��","�").Replace("ß","�").Replace("�","�").Replace("ñ","�").Replace("��","�").Replace("Ñ","�").Replace("�","�").Replace("â","�").Replace("��","�").Replace("Â�","�") `
                    | Out-File $ORAOutConvertedFileNameFullPath -Encoding utf32 -Append

                }

                if($?)
                {
                    Write-Host " =>Conversion terminee OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant la conversion"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }

                Write-Host ""
                Write-Host "Suppression du fichier originel '${ORAOutFileNameFullPath}' en cours..."
                Remove-Item $ORAOutFileNameFullPath -Force

                if($?)
                {
                    Write-Host " =>Suppression OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant la suppression"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }

                Write-Host ""
                Write-Host "Renommage fichier converti '$ORAOutConvertedFileNameFullPath' en '${ORAOutFileNameFullPath}' en cours..."
                Move-Item -Path $ORAOutConvertedFileNameFullPath -Destination $ORAOutFileNameFullPath

                if($?)
                {
                    Write-Host " =>Renommage OK -OK"
                }
                else
                {
                    Write-Host " =>Erreur durant le renommage -KOKOKO"
                    Write-Host " =>Analyser Erreur"
                    Write-Host ""
                    Write-Host "--------------------------------"
                    Write-Host " TRT TERMINE EN ERREUR -KOKOKO  "
                    Write-Host "--------------------------------"

                    Exit 1 
                }



            }
            
            default{
                Write-Host " =>Type de format non gerer -KOKOKO"
                Write-Host " =>Le fichier ne sera pas modifie"
            }
        
        }
    }

    Write-Host ""
    Write-Host "------------------------------"
    Write-Host " TRT TERMINE AVEC SUCCES -OK  "
    Write-Host "------------------------------"


    Exit 0

}


# ======================================
#    Execution du PROGRAMME
# ======================================

#    Arg1:serveur ORACLE -Server:Port, Arg2: Declaration de la DB, Arg3: SQL Query File, Arg4: ORA User, Arg5: ORA Pwd, Arg6: chemin de sortie, Arg7: Nom du rapport, Arg8: separateur Colonne, Arg9: Argument Query SQLCL Param1, Arg10: Argument Query SQLCL Param2, Arg11: Argument Query SQLCL Param3, arg11: Definition du parametre de conversion/encodage{ASCII,UTF8,UTF32}
main $argORAServeurAndPort $argORADB $argORAQueryBaseFilePath $argORAProtectedUser $argORAProtectedPwd $argORAOutFilePath $argORAReportFileName $argORAColSeparator $argORAParameter1 $argORAParameter2 $argORAParameter3 $argForceEncodingOutFileParam