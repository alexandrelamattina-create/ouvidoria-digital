# 🚀 OuviDigital - MVP Funcional

## Sistema de Ouvidoria Pública Inteligente
### MVP Completo com Backend + Frontend + Banco de Dados

---

## ✨ O que este MVP TEM:

### ✅ **CRUD COMPLETO E FUNCIONAL:**
- **CREATE** - Criar novas manifestações
- **READ** - Listar e visualizar manifestações
- **UPDATE** - Editar status, resposta e responsável
- **DELETE** - Excluir manifestações

### ✅ **Backend Completo:**
- API REST em Node.js + Express
- Banco de dados SQLite (persistente)
- 8 endpoints funcionais
- Validações e tratamento de erros
- Histórico de alterações

### ✅ **Frontend Responsivo:**
- Interface moderna e intuitiva
- Listagem com filtros e busca
- Formulário de criação
- Modal de edição
- Dashboard de estatísticas
- Indicador de conexão em tempo real

### ✅ **Features Avançadas:**
- Geração automática de protocolos únicos
- Cálculo de prazos (SLA)
- Estatísticas em tempo real
- Filtros por status e busca textual
- Sistema de categorização
- Priorização de manifestações

---

## 📋 Requisitos

- **Node.js** versão 14 ou superior
- **npm** (vem com o Node.js)

---

## 🚀 Como Instalar e Rodar

### **Passo 1: Instalar Dependências**

Abra o terminal na pasta `ouvidoria-backend` e execute:

```bash
npm install
```

Isso irá instalar:
- express (servidor web)
- sqlite3 (banco de dados)
- cors (permitir requisições cross-origin)
- body-parser (processar JSON)

### **Passo 2: Iniciar o Servidor**

```bash
npm start
```

Você verá:
```
🚀 ========================================
🎉 SERVIDOR OUVIDORIA DIGITAL INICIADO!
🚀 ========================================

📍 Servidor rodando em: http://localhost:3000
📊 API disponível em: http://localhost:3000/api
💾 Banco de dados: ouvidoria.db (SQLite)
```

### **Passo 3: Acessar o Sistema**

Abra seu navegador e acesse:

```
http://localhost:3000
```

**PRONTO!** O sistema está funcionando! 🎉

---

## 📡 Endpoints da API

### **Manifestações:**

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/manifestacoes` | Listar todas |
| GET | `/api/manifestacoes/:id` | Buscar por ID |
| POST | `/api/manifestacoes` | Criar nova |
| PUT | `/api/manifestacoes/:id` | Atualizar |
| DELETE | `/api/manifestacoes/:id` | Excluir |

### **Estatísticas:**

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/estatisticas` | Estatísticas gerais |
| GET | `/api/manifestacoes/:id/historico` | Histórico de uma manifestação |

### **Filtros Disponíveis (Query Params):**

```
GET /api/manifestacoes?status=Nova
GET /api/manifestacoes?search=buraco
GET /api/manifestacoes?status=Respondida&search=saude
```

---

## 💾 Banco de Dados

O sistema usa **SQLite** - um banco de dados em arquivo único.

**Arquivo:** `ouvidoria.db` (criado automaticamente na primeira execução)

### **Tabelas:**

1. **manifestacoes** - Dados principais
2. **historico** - Log de todas as alterações

### **Dados de Exemplo:**

O sistema vem com 3 manifestações de exemplo que são inseridas automaticamente na primeira execução.

---

## 🧪 Testando a API

### **Criar nova manifestação (POST):**

```bash
curl -X POST http://localhost:3000/api/manifestacoes \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "Reclamação",
    "categoria": "Saúde",
    "assunto": "Teste de API",
    "descricao": "Esta é uma manifestação criada via API",
    "cidadao": "João Teste",
    "email": "joao@test.com",
    "telefone": "(11) 99999-9999",
    "canal": "API",
    "prioridade": "Alta",
    "prazoLegal": 15
  }'
```

### **Listar todas (GET):**

```bash
curl http://localhost:3000/api/manifestacoes
```

### **Atualizar status (PUT):**

```bash
curl -X PUT http://localhost:3000/api/manifestacoes/1 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Respondida",
    "resposta": "Sua solicitação foi atendida.",
    "responsavel": "Secretaria de Saúde"
  }'
```

### **Deletar (DELETE):**

```bash
curl -X DELETE http://localhost:3000/api/manifestacoes/1
```

---

## 📂 Estrutura de Arquivos

```
ouvidoria-backend/
├── server.js           # Backend (API + Lógica)
├── package.json        # Dependências
├── ouvidoria.db        # Banco de dados (criado automaticamente)
└── public/
    └── index.html      # Frontend (Interface)
```

---

## 🎨 Personalizações Rápidas

### **Mudar o nome do sistema:**

Edite `public/index.html` linha 17:

```html
<h1 class="text-2xl font-bold">OuviDigital MVP</h1>
```

Para:

```html
<h1 class="text-2xl font-bold">Ouvidoria de [Sua Cidade]</h1>
```

### **Mudar a porta do servidor:**

Edite `server.js` linha 6:

```javascript
const PORT = 3000;
```

Para:

```javascript
const PORT = 8080; // ou outra porta
```

### **Adicionar mais categorias:**

Edite `public/index.html` nas linhas do select de categoria.

---

## 🐛 Solução de Problemas

### **Erro: "Cannot find module"**

```bash
npm install
```

### **Erro: "Port 3000 already in use"**

Mude a porta no `server.js` ou mate o processo:

```bash
# Linux/Mac
lsof -ti:3000 | xargs kill -9

# Windows
netstat -ano | findstr :3000
taskkill /PID [número] /F
```

### **Banco de dados corrompido:**

Delete o arquivo `ouvidoria.db` e reinicie o servidor (será recriado).

---

## 📦 Deploy em Produção

### **Opção 1 - Railway (Recomendado):**

1. Crie conta em: https://railway.app
2. Conecte seu repositório GitHub
3. Railway detecta Node.js automaticamente
4. Deploy feito! URL tipo: `https://seu-app.railway.app`

### **Opção 2 - Heroku:**

```bash
# Instalar Heroku CLI
npm install -g heroku

# Login
heroku login

# Criar app
heroku create ouvidoria-digital

# Deploy
git push heroku main
```

### **Opção 3 - VPS (Digital Ocean, AWS, etc):**

```bash
# Instalar Node.js no servidor
# Clonar repositório
git clone seu-repo
cd ouvidoria-backend

# Instalar dependências
npm install

# Usar PM2 para manter rodando
npm install -g pm2
pm2 start server.js
pm2 save
pm2 startup
```

---

## 🔐 Segurança (Para Produção)

**⚠️ IMPORTANTE:** Este MVP não tem autenticação!

Para produção, adicione:

1. **Autenticação JWT**
2. **HTTPS obrigatório**
3. **Rate limiting**
4. **Validação de inputs**
5. **Logs de auditoria**
6. **Backup automático do banco**

---

## 📈 Próximos Passos (Roadmap)

- [ ] Sistema de login/autenticação
- [ ] Permissões por cargo (admin, atendente, cidadão)
- [ ] Envio de emails automáticos
- [ ] Integração WhatsApp Business API
- [ ] Upload de arquivos (fotos, documentos)
- [ ] Relatórios em PDF
- [ ] Painel de BI/Analytics
- [ ] App mobile (React Native)
- [ ] Integração com e-SIC
- [ ] Triagem automática com IA

---

## 🆘 Suporte

Problemas? Entre em contato ou abra uma issue!

---

## 📄 Licença

MIT License - Use livremente!

---

**Desenvolvido com ❤️ para melhorar o atendimento ao cidadão**
