# ===========================================
# Script PowerShell : Configuration DHCP
# Entreprise : EntrepriseXYZ
# Étendue : LAN_EntrepriseXYZ
# ===========================================

# Variables de configuration
$ScopeName     = "LAN_EntrepriseXYZ"
$ScopeStart    = "192.168.147.200"
$ScopeEnd      = "192.168.147.220"
$SubnetMask    = "255.255.255.0"
$Gateway       = "192.168.147.1"
$DNSServer     = "192.168.147.10"
$DomainName    = "entreprisexyz.local"

# Adresse IP de réservation
$ReservedIP    = "192.168.147.210"
$MACAddress    = "00-11-22-33-44-55"   # <-- Remplace par le vrai MAC du poste administratif
$ReservationName = "Poste_Admin"

# ===========================================
# Création de l’étendue DHCP
# ===========================================
Add-DhcpServerv4Scope -Name $ScopeName -StartRange $ScopeStart -EndRange $ScopeEnd -SubnetMask $SubnetMask -State Active

# Configuration des options de l’étendue
Set-DhcpServerv4OptionValue -ScopeId 192.168.147.0 `
    -DnsServer $DNSServer `
    -Router $Gateway `
    -DnsDomain $DomainName

# ===========================================
# Création de la réservation pour le poste administratif
# ===========================================
Add-DhcpServerv4Reservation -ScopeId 192.168.147.0 `
    -IPAddress $ReservedIP `
    -ClientId $MACAddress `
    -Description "Réservation pour le poste administratif" `
    -Name $ReservationName

Write-Host " Étendue DHCP '$ScopeName' créée et configurée avec succès."
Write-Host " Réservation ajoutée pour $ReservationName ($ReservedIP)."
