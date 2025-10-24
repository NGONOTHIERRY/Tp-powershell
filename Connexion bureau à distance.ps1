<#
    Script PowerShell - Déploiement complet RDS
    Domaine : iticsio2.fr
    Rôles : RD Session Host, RD Web Access, RD Connection Broker
    Collection : Collection_Bureau
    RemoteApps : Bloc-notes & Calculatrice
#>

# ========================
# === VARIABLES GLOBALES ==
# ========================

$DomainName = "iticsio2.fr"
$ServerName = "SDN2.iticsio2.fr"  
$CollectionName = "Collection_Bureau"
$UserGroup = "$DomainName\Utilisateurs du domaine"

Write-Host "=== Début du déploiement RDS sur $ServerName ($DomainName) ===" -ForegroundColor Cyan

# ======================================
# === 1. INSTALLATION DES RÔLES RDS ====
# ======================================

Write-Host "`n[1/4] Installation des rôles RDS..." -ForegroundColor Yellow

Install-WindowsFeature -Name RDS-RD-Server -IncludeAllSubFeature -IncludeManagementTools -ErrorAction Stop
Install-WindowsFeature -Name RDS-Web-Access -IncludeAllSubFeature -IncludeManagementTools -ErrorAction Stop
Install-WindowsFeature -Name RDS-Connection-Broker -IncludeAllSubFeature -IncludeManagementTools -ErrorAction Stop

Write-Host "✅ Rôles RDS installés avec succès." -ForegroundColor Green

# ===================================
# === 2. CREATION DU DEPLOIEMENT RDS ==
# ===================================

Write-Host "`n[2/4] Création du déploiement RDS..." -ForegroundColor Yellow

# Vérifie si le déploiement existe déjà
try {
    $existingDeployment = Get-RDDeployment
    if ($existingDeployment) {
        Write-Host " Un déploiement RDS existe déjà. Étape ignorée." -ForegroundColor Cyan
    }
} catch {
    Write-Host "Aucun déploiement RDS trouvé. Création en cours..." -ForegroundColor Cyan
    New-RDSessionDeployment -ConnectionBroker $ServerName -WebAccessServer $ServerName -SessionHost $ServerName -ErrorAction Stop
    Write-Host " Déploiement RDS créé avec succès." -ForegroundColor Green
}

# ====================================
# === 3. CREATION DE LA COLLECTION ====
# ====================================

Write-Host "`n[3/4] Création de la collection de sessions..." -ForegroundColor Yellow

# Vérifie si la collection existe
$existingCollection = Get-RDSessionCollection -ConnectionBroker $ServerName -ErrorAction SilentlyContinue | Where-Object { $_.CollectionName -eq $CollectionName }

if ($existingCollection) {
    Write-Host " La collection '$CollectionName' existe déjà. Étape ignorée." -ForegroundColor Cyan
} else {
    New-RDSessionCollection -CollectionName $CollectionName `
                            -SessionHost $ServerName `
                            -ConnectionBroker $ServerName `
                            -CollectionDescription "Collection de bureau à distance pour les utilisateurs du domaine $DomainName" -ErrorAction Stop

    Write-Host "✅ Collection '$CollectionName' créée avec succès." -ForegroundColor Green
}

# Attribution du groupe "Utilisateurs du domaine"
Set-RDSessionCollectionConfiguration -CollectionName $CollectionName -UserGroup $UserGroup -ConnectionBroker $ServerName -ErrorAction Stop

Write-Host " Groupe '$UserGroup' autorisé à se connecter à la collection." -ForegroundColor Green

# ====================================
# === 4. PUBLICATION DES REMOTEAPPS ===
# ====================================

Write-Host "`n[4/4] Publication des applications RemoteApp..." -ForegroundColor Yellow

# Bloc-notes
New-RDRemoteApp -CollectionName $CollectionName `
                -DisplayName "Bloc-notes" `
                -FilePath "C:\Windows\System32\notepad.exe" `
                -ConnectionBroker $ServerName -ErrorAction SilentlyContinue

# Calculatrice
New-RDRemoteApp -CollectionName $CollectionName `
                -DisplayName "Calculatrice" `
                -FilePath "C:\Windows\System32\calc.exe" `
                -ConnectionBroker $ServerName -ErrorAction SilentlyContinue

Write-Host "✅ Applications RemoteApp (Bloc-notes et Calculatrice) publiées avec succès." -ForegroundColor Green

# ===============================
# === FIN DU SCRIPT ============
# ===============================

Write-Host " Déploiement RDS terminé avec succès sur $ServerName ($DomainName)" -ForegroundColor Cyan
Write-Host "Vous pouvez maintenant accéder au portail via : https://$ServerName/RDWeb" -ForegroundColor Magenta
