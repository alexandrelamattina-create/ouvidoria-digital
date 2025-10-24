#!/bin/bash

# 🚀 SCRIPT DE SETUP AUTOMÁTICO - OUVIDORIA DIGITAL + GITHUB
# Execute este script para configurar tudo automaticamente

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   🚀 SETUP AUTOMÁTICO - OUVIDORIA DIGITAL + GITHUB       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para verificar comandos
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 está instalado"
        return 0
    else
        echo -e "${RED}✗${NC} $1 NÃO está instalado"
        return 1
    fi
}

# Verificar pré-requisitos
echo "📋 Verificando pré-requisitos..."
echo ""

has_node=false
has_git=false

if check_command "node"; then
    NODE_VERSION=$(node --version)
    echo "   Versão: $NODE_VERSION"
    has_node=true
fi

if check_command "git"; then
    GIT_VERSION=$(git --version)
    echo "   $GIT_VERSION"
    has_git=true
fi

echo ""

# Se faltam dependências
if [ "$has_node" = false ] || [ "$has_git" = false ]; then
    echo -e "${YELLOW}⚠️  Dependências faltando!${NC}"
    echo ""
    
    if [ "$has_node" = false ]; then
        echo "Node.js não encontrado. Instale em: https://nodejs.org"
    fi
    
    if [ "$has_git" = false ]; then
        echo "Git não encontrado. Instale em: https://git-scm.com"
    fi
    
    echo ""
    echo "Após instalar, execute este script novamente."
    exit 1
fi

# Tudo OK
echo -e "${GREEN}✓ Todos os pré-requisitos estão OK!${NC}"
echo ""

# Perguntar nome do usuário
echo "═══════════════════════════════════════════════════════════"
echo "📝 CONFIGURAÇÃO INICIAL"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Verificar se Git já está configurado
GIT_NAME=$(git config --global user.name)
GIT_EMAIL=$(git config --global user.email)

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo "Git ainda não está configurado."
    echo ""
    read -p "Digite seu nome: " USER_NAME
    read -p "Digite seu email: " USER_EMAIL
    
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"
    
    echo ""
    echo -e "${GREEN}✓ Git configurado com sucesso!${NC}"
else
    echo "Git já configurado:"
    echo "  Nome: $GIT_NAME"
    echo "  Email: $GIT_EMAIL"
fi

echo ""

# Instalar dependências
echo "═══════════════════════════════════════════════════════════"
echo "📦 INSTALANDO DEPENDÊNCIAS"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ -f "package.json" ]; then
    echo "Instalando pacotes npm..."
    npm install
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Dependências instaladas com sucesso!${NC}"
    else
        echo ""
        echo -e "${RED}✗ Erro ao instalar dependências${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ package.json não encontrado!${NC}"
    echo "Execute este script na pasta 'ouvidoria-backend'"
    exit 1
fi

echo ""

# Inicializar Git
echo "═══════════════════════════════════════════════════════════"
echo "🔧 CONFIGURANDO GIT REPOSITORY"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Repositório Git já existe${NC}"
    read -p "Deseja reinicializar? (s/N): " REINIT
    
    if [ "$REINIT" = "s" ] || [ "$REINIT" = "S" ]; then
        rm -rf .git
        git init
        echo -e "${GREEN}✓ Repositório reinicializado${NC}"
    fi
else
    git init
    echo -e "${GREEN}✓ Repositório Git inicializado${NC}"
fi

echo ""

# Adicionar arquivos
echo "Adicionando arquivos ao Git..."
git add .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Arquivos adicionados${NC}"
else
    echo -e "${RED}✗ Erro ao adicionar arquivos${NC}"
    exit 1
fi

echo ""

# Fazer commit inicial
echo "Criando commit inicial..."
git commit -m "🚀 Versão inicial - Ouvidoria Digital MVP" -m "Sistema completo com CRUD funcional, API REST e interface web"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Commit criado${NC}"
else
    echo -e "${YELLOW}⚠️  Commit já existe ou erro${NC}"
fi

echo ""

# Conectar com GitHub
echo "═══════════════════════════════════════════════════════════"
echo "🔗 CONECTAR COM GITHUB"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Para continuar, você precisa:"
echo "1. Criar um repositório no GitHub:"
echo "   → Acesse: https://github.com/new"
echo "   → Nome: ouvidoria-digital"
echo "   → Tipo: Public ou Private"
echo "   → NÃO marque 'Add README'"
echo ""
echo "2. Após criar, copie a URL do repositório"
echo "   Exemplo: https://github.com/seu-usuario/ouvidoria-digital.git"
echo ""

read -p "Cole a URL do seu repositório GitHub: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${YELLOW}⚠️  URL não fornecida. Você pode fazer isso manualmente depois:${NC}"
    echo ""
    echo "git remote add origin SUA-URL"
    echo "git branch -M main"
    echo "git push -u origin main"
    echo ""
else
    # Verificar se remote já existe
    if git remote get-url origin &> /dev/null; then
        echo -e "${YELLOW}⚠️  Remote 'origin' já existe${NC}"
        read -p "Deseja substituir? (s/N): " REPLACE
        
        if [ "$REPLACE" = "s" ] || [ "$REPLACE" = "S" ]; then
            git remote remove origin
            git remote add origin "$REPO_URL"
            echo -e "${GREEN}✓ Remote atualizado${NC}"
        fi
    else
        git remote add origin "$REPO_URL"
        echo -e "${GREEN}✓ Repositório conectado${NC}"
    fi
    
    echo ""
    echo "Enviando código para GitHub..."
    git branch -M main
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓✓✓ CÓDIGO ENVIADO PARA GITHUB COM SUCESSO! ✓✓✓${NC}"
    else
        echo ""
        echo -e "${RED}✗ Erro ao enviar código${NC}"
        echo ""
        echo "Possíveis causas:"
        echo "• Autenticação não configurada"
        echo "• Repositório não existe"
        echo "• Sem permissão"
        echo ""
        echo "Configure autenticação e tente manualmente:"
        echo "git push -u origin main"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ SETUP CONCLUÍDO!${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "🎯 Próximos passos:"
echo ""
echo "1️⃣  Testar localmente:"
echo "   npm start"
echo "   Acesse: http://localhost:3000"
echo ""
echo "2️⃣  Deploy automático (Railway):"
echo "   → Acesse: https://railway.app"
echo "   → Login com GitHub"
echo "   → Deploy from GitHub repo"
echo "   → Selecione: ouvidoria-digital"
echo ""
echo "3️⃣  Comandos úteis:"
echo "   git status           → Ver mudanças"
echo "   git add .            → Adicionar arquivos"
echo "   git commit -m '...'  → Salvar mudanças"
echo "   git push             → Enviar para GitHub"
echo ""
echo "📚 Documentação completa em:"
echo "   → README.md"
echo "   → GUIA-GITHUB-COMPLETO.md"
echo ""
echo -e "${GREEN}Bom desenvolvimento! 🚀${NC}"
echo ""
