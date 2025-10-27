<#
Script para automatizar o push das alterações ao repositório GitHub fornecido.
Como usar:
  1) Abra PowerShell como usuário que tem git instalado.
  2) Navegue até a pasta do projeto (onde está app.py) OU execute este script diretamente.
  3) Execute: .\tools\push_to_github.ps1

Observações:
- Este script usa HTTPS remoto. Se quiser usar SSH, altere a variável $remoteUrl para a forma SSH.
- Se o Git não estiver instalado, instale-o primeiro: https://git-scm.com/downloads
- Para autenticação HTTPS no GitHub, utilize um Personal Access Token (PAT) como senha se solicitado.
#>

param(
    [string]$remoteUrl = 'https://github.com/Alvasync/ProjetoIntegrador1.git',
    [string]$branchName = 'feature/city-select-sao-jose',
    [string]$commitMessage = 'UI: add city select (Jacareí + São José disabled) and improve price card; include city in API',
    [string[]]$filesToAdd = @('templates/index.html', 'app.py', 'tools/render_test.py')
)

function Fail($msg){
    Write-Error $msg
    exit 1
}

# Caminho do script (pasta do projeto)
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot
Write-Host "Working directory: $projectRoot"

# Verificar se git está disponível
try {
    git --version > $null 2>&1
} catch {
    Fail "Git não foi encontrado. Instale o Git (https://git-scm.com/downloads) e execute novamente este script."
}

# Inicializar repo se necessário
if (-not (Test-Path .git)) {
    Write-Host "Inicializando repositório git local..."
    git init || Fail "Falha ao inicializar git"
} else {
    Write-Host ".git já existe — usando repositório local existente"
}

# Configurar remote
$existingRemote = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Remote 'origin' já configurado: $existingRemote"
    if ($existingRemote -ne $remoteUrl) {
        Write-Host "Atualizando URL do remote 'origin' para: $remoteUrl"
        git remote set-url origin $remoteUrl || Fail "Falha ao atualizar remote origin"
    }
} else {
    Write-Host "Adicionando remote origin -> $remoteUrl"
    git remote add origin $remoteUrl || Fail "Falha ao adicionar remote origin"
}

# Criar/Checkout da branch
$curBranch = git rev-parse --abbrev-ref HEAD
if ($curBranch -ne $branchName) {
    Write-Host "Criando/alternando para branch: $branchName"
    git checkout -b $branchName 2>$null || git checkout $branchName 2>$null || Fail "Falha ao criar/alternar para branch $branchName"
} else {
    Write-Host "Já está na branch $branchName"
}

# Adicionar arquivos
Write-Host "Adicionando arquivos: $($filesToAdd -join ', ')"
foreach ($f in $filesToAdd) {
    if (Test-Path $f) {
        git add $f || Fail "Falha ao adicionar $f"
    } else {
        Write-Warning "Arquivo não encontrado (ignorando): $f"
    }
}

# Commit
# Checar se há algo a commitar
$changes = git status --porcelain
if (-not [string]::IsNullOrWhiteSpace($changes)) {
    git commit -m "$commitMessage" || Fail "Falha ao commitar"
    Write-Host "Commit criado: $commitMessage"
} else {
    Write-Host "Nenhuma alteração detectada para commitar. Pulando commit."
}

# Push
Write-Host "Enviando branch '$branchName' para origin..."
# Usar push com upstream
git push -u origin $branchName || Fail "Falha ao dar push. Verifique credenciais e rede."

Write-Host "Push realizado com sucesso. Abra o repositório no GitHub e crie um Pull Request a partir da branch '$branchName'."