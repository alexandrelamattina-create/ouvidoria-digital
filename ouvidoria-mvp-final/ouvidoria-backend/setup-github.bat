@echo off
setlocal enabledelayedexpansion

REM 🚀 SCRIPT DE SETUP AUTOMÁTICO - OUVIDORIA DIGITAL + GITHUB (Windows)

echo ╔═══════════════════════════════════════════════════════════╗
echo ║   🚀 SETUP AUTOMÁTICO - OUVIDORIA DIGITAL + GITHUB       ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

REM Verificar Node.js
where node >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Node.js está instalado
    node --version
) else (
    echo [ERRO] Node.js NÃO está instalado
    echo.
    echo Baixe em: https://nodejs.org
    echo Após instalar, execute este script novamente.
    pause
    exit /b 1
)

echo.

REM Verificar Git
where git >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Git está instalado
    git --version
) else (
    echo [ERRO] Git NÃO está instalado
    echo.
    echo Baixe em: https://git-scm.com
    echo Após instalar, execute este script novamente.
    pause
    exit /b 1
)

echo.
echo ═══════════════════════════════════════════════════════════
echo 📦 INSTALANDO DEPENDÊNCIAS
echo ═══════════════════════════════════════════════════════════
echo.

if exist package.json (
    echo Instalando pacotes npm...
    call npm install
    
    if %errorlevel% equ 0 (
        echo.
        echo [OK] Dependências instaladas com sucesso!
    ) else (
        echo.
        echo [ERRO] Erro ao instalar dependências
        pause
        exit /b 1
    )
) else (
    echo [ERRO] package.json não encontrado!
    echo Execute este script na pasta 'ouvidoria-backend'
    pause
    exit /b 1
)

echo.
echo ═══════════════════════════════════════════════════════════
echo 🔧 CONFIGURANDO GIT
echo ═══════════════════════════════════════════════════════════
echo.

REM Verificar configuração do Git
git config --global user.name >nul 2>&1
if %errorlevel% neq 0 (
    echo Git ainda não está configurado.
    echo.
    set /p USER_NAME="Digite seu nome: "
    set /p USER_EMAIL="Digite seu email: "
    
    git config --global user.name "!USER_NAME!"
    git config --global user.email "!USER_EMAIL!"
    
    echo.
    echo [OK] Git configurado com sucesso!
) else (
    echo Git já está configurado.
    echo Nome: 
    git config --global user.name
    echo Email: 
    git config --global user.email
)

echo.

REM Inicializar repositório
if exist .git (
    echo [AVISO] Repositório Git já existe
) else (
    git init
    echo [OK] Repositório Git inicializado
)

echo.
echo Adicionando arquivos ao Git...
git add .
echo [OK] Arquivos adicionados

echo.
echo Criando commit inicial...
git commit -m "🚀 Versão inicial - Ouvidoria Digital MVP" -m "Sistema completo com CRUD funcional" >nul 2>&1
echo [OK] Commit criado

echo.
echo ═══════════════════════════════════════════════════════════
echo 🔗 CONECTAR COM GITHUB
echo ═══════════════════════════════════════════════════════════
echo.
echo Para continuar, você precisa:
echo 1. Criar um repositório no GitHub:
echo    → Acesse: https://github.com/new
echo    → Nome: ouvidoria-digital
echo    → Tipo: Public ou Private
echo    → NÃO marque 'Add README'
echo.
echo 2. Após criar, copie a URL do repositório
echo    Exemplo: https://github.com/seu-usuario/ouvidoria-digital.git
echo.

set /p REPO_URL="Cole a URL do seu repositório GitHub: "

if "!REPO_URL!"=="" (
    echo.
    echo [AVISO] URL não fornecida.
    echo Você pode fazer isso manualmente depois:
    echo.
    echo git remote add origin SUA-URL
    echo git branch -M main
    echo git push -u origin main
) else (
    git remote remove origin >nul 2>&1
    git remote add origin "!REPO_URL!"
    echo [OK] Repositório conectado
    
    echo.
    echo Enviando código para GitHub...
    git branch -M main
    git push -u origin main
    
    if %errorlevel% equ 0 (
        echo.
        echo [OK] ✓✓✓ CÓDIGO ENVIADO PARA GITHUB COM SUCESSO! ✓✓✓
    ) else (
        echo.
        echo [ERRO] Erro ao enviar código
        echo.
        echo Possíveis causas:
        echo • Autenticação não configurada
        echo • Repositório não existe
        echo • Sem permissão
        echo.
        echo Configure autenticação e tente manualmente:
        echo git push -u origin main
    )
)

echo.
echo ═══════════════════════════════════════════════════════════
echo [OK] SETUP CONCLUÍDO!
echo ═══════════════════════════════════════════════════════════
echo.
echo 🎯 Próximos passos:
echo.
echo 1️⃣  Testar localmente:
echo    npm start
echo    Acesse: http://localhost:3000
echo.
echo 2️⃣  Deploy automático (Railway):
echo    → Acesse: https://railway.app
echo    → Login com GitHub
echo    → Deploy from GitHub repo
echo    → Selecione: ouvidoria-digital
echo.
echo 3️⃣  Comandos úteis:
echo    git status           → Ver mudanças
echo    git add .            → Adicionar arquivos
echo    git commit -m "..."  → Salvar mudanças
echo    git push             → Enviar para GitHub
echo.
echo 📚 Documentação completa em:
echo    → README.md
echo    → GUIA-GITHUB-COMPLETO.md
echo.
echo Bom desenvolvimento! 🚀
echo.

pause
