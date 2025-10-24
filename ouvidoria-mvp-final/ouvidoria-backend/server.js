const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));

// Inicializar banco de dados SQLite
const db = new sqlite3.Database('./ouvidoria.db', (err) => {
    if (err) {
        console.error('Erro ao conectar ao banco de dados:', err);
    } else {
        console.log('✅ Conectado ao banco de dados SQLite');
        initDatabase();
    }
});

// Criar tabelas
function initDatabase() {
    db.run(`
        CREATE TABLE IF NOT EXISTS manifestacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            protocolo TEXT UNIQUE NOT NULL,
            tipo TEXT NOT NULL,
            categoria TEXT NOT NULL,
            assunto TEXT NOT NULL,
            descricao TEXT NOT NULL,
            cidadao TEXT NOT NULL,
            email TEXT,
            telefone TEXT,
            canal TEXT NOT NULL,
            status TEXT DEFAULT 'Nova',
            prioridade TEXT DEFAULT 'Média',
            dataAbertura DATETIME DEFAULT CURRENT_TIMESTAMP,
            prazoLegal INTEGER DEFAULT 20,
            diasRestantes INTEGER,
            responsavel TEXT,
            resposta TEXT,
            dataResposta DATETIME,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `, (err) => {
        if (err) {
            console.error('Erro ao criar tabela:', err);
        } else {
            console.log('✅ Tabela manifestacoes criada/verificada');
            inserirDadosIniciais();
        }
    });

    db.run(`
        CREATE TABLE IF NOT EXISTS historico (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            manifestacao_id INTEGER NOT NULL,
            evento TEXT NOT NULL,
            usuario TEXT NOT NULL,
            data DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (manifestacao_id) REFERENCES manifestacoes(id)
        )
    `);
}

// Inserir dados de exemplo (apenas se tabela estiver vazia)
function inserirDadosIniciais() {
    db.get('SELECT COUNT(*) as count FROM manifestacoes', (err, row) => {
        if (row.count === 0) {
            console.log('📝 Inserindo dados de exemplo...');
            
            const exemplos = [
                {
                    protocolo: '202410240001',
                    tipo: 'Reclamação',
                    categoria: 'Saúde',
                    assunto: 'Demora no atendimento UBS',
                    descricao: 'Esperei 4 horas para ser atendida na UBS do bairro Centro.',
                    cidadao: 'Maria Silva',
                    email: 'maria.silva@email.com',
                    telefone: '(11) 98765-4321',
                    canal: 'Aplicativo',
                    status: 'Em Análise',
                    prioridade: 'Alta',
                    prazoLegal: 20,
                    diasRestantes: 16,
                    responsavel: 'Secretaria de Saúde'
                },
                {
                    protocolo: '202410240002',
                    tipo: 'Solicitação',
                    categoria: 'Infraestrutura',
                    assunto: 'Buraco na Rua Principal',
                    descricao: 'Existe um buraco grande na Rua Principal, altura do nº 450.',
                    cidadao: 'João Santos',
                    email: 'joao.santos@email.com',
                    telefone: '(11) 91234-5678',
                    canal: 'WhatsApp',
                    status: 'Respondida',
                    prioridade: 'Média',
                    prazoLegal: 20,
                    diasRestantes: 14,
                    responsavel: 'Secretaria de Obras',
                    resposta: 'Equipe foi acionada e previsão de reparo é de 5 dias úteis.'
                },
                {
                    protocolo: '202410240003',
                    tipo: 'Elogio',
                    categoria: 'Educação',
                    assunto: 'Excelente atendimento escola',
                    descricao: 'Gostaria de elogiar o atendimento da diretora da Escola Municipal.',
                    cidadao: 'Ana Costa',
                    email: 'ana.costa@email.com',
                    telefone: '(11) 99876-5432',
                    canal: 'Portal Web',
                    status: 'Finalizada',
                    prioridade: 'Baixa',
                    prazoLegal: 20,
                    diasRestantes: 11,
                    responsavel: 'Secretaria de Educação',
                    resposta: 'Agradecemos seu feedback! Ele será repassado à equipe.'
                }
            ];

            const stmt = db.prepare(`
                INSERT INTO manifestacoes (
                    protocolo, tipo, categoria, assunto, descricao, 
                    cidadao, email, telefone, canal, status, prioridade, 
                    prazoLegal, diasRestantes, responsavel, resposta
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            `);

            exemplos.forEach(ex => {
                stmt.run([
                    ex.protocolo, ex.tipo, ex.categoria, ex.assunto, ex.descricao,
                    ex.cidadao, ex.email, ex.telefone, ex.canal, ex.status,
                    ex.prioridade, ex.prazoLegal, ex.diasRestantes, 
                    ex.responsavel, ex.resposta
                ]);
            });

            stmt.finalize();
            console.log('✅ Dados de exemplo inseridos');
        }
    });
}

// ==================== ROTAS DA API ====================

// GET - Listar todas as manifestações
app.get('/api/manifestacoes', (req, res) => {
    const { status, search } = req.query;
    
    let query = 'SELECT * FROM manifestacoes WHERE 1=1';
    const params = [];

    if (status && status !== 'Todas') {
        query += ' AND status = ?';
        params.push(status);
    }

    if (search) {
        query += ' AND (assunto LIKE ? OR protocolo LIKE ? OR cidadao LIKE ?)';
        const searchTerm = `%${search}%`;
        params.push(searchTerm, searchTerm, searchTerm);
    }

    query += ' ORDER BY dataAbertura DESC';

    db.all(query, params, (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            res.json(rows);
        }
    });
});

// GET - Buscar manifestação por ID
app.get('/api/manifestacoes/:id', (req, res) => {
    db.get('SELECT * FROM manifestacoes WHERE id = ?', [req.params.id], (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (!row) {
            res.status(404).json({ error: 'Manifestação não encontrada' });
        } else {
            res.json(row);
        }
    });
});

// POST - Criar nova manifestação
app.post('/api/manifestacoes', (req, res) => {
    const {
        tipo, categoria, assunto, descricao, cidadao,
        email, telefone, canal, prioridade, prazoLegal
    } = req.body;

    // Gerar protocolo único
    const protocolo = `${new Date().getFullYear()}${String(new Date().getMonth() + 1).padStart(2, '0')}${String(new Date().getDate()).padStart(2, '0')}${Date.now().toString().slice(-5)}`;

    const query = `
        INSERT INTO manifestacoes (
            protocolo, tipo, categoria, assunto, descricao,
            cidadao, email, telefone, canal, prioridade,
            prazoLegal, diasRestantes, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Nova')
    `;

    db.run(query, [
        protocolo, tipo, categoria, assunto, descricao,
        cidadao, email, telefone, canal, prioridade,
        prazoLegal, prazoLegal
    ], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            // Buscar a manifestação criada
            db.get('SELECT * FROM manifestacoes WHERE id = ?', [this.lastID], (err, row) => {
                if (err) {
                    res.status(500).json({ error: err.message });
                } else {
                    // Registrar no histórico
                    db.run(
                        'INSERT INTO historico (manifestacao_id, evento, usuario) VALUES (?, ?, ?)',
                        [this.lastID, 'Manifestação registrada', 'Sistema']
                    );
                    res.status(201).json(row);
                }
            });
        }
    });
});

// PUT - Atualizar manifestação
app.put('/api/manifestacoes/:id', (req, res) => {
    const { status, resposta, responsavel, prioridade } = req.body;
    const updates = [];
    const params = [];

    if (status) {
        updates.push('status = ?');
        params.push(status);
    }
    if (resposta) {
        updates.push('resposta = ?');
        params.push(resposta);
        updates.push('dataResposta = CURRENT_TIMESTAMP');
    }
    if (responsavel) {
        updates.push('responsavel = ?');
        params.push(responsavel);
    }
    if (prioridade) {
        updates.push('prioridade = ?');
        params.push(prioridade);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    params.push(req.params.id);

    const query = `UPDATE manifestacoes SET ${updates.join(', ')} WHERE id = ?`;

    db.run(query, params, function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
        } else {
            // Registrar no histórico
            if (status) {
                db.run(
                    'INSERT INTO historico (manifestacao_id, evento, usuario) VALUES (?, ?, ?)',
                    [req.params.id, `Status alterado para: ${status}`, 'Admin']
                );
            }
            if (responsavel) {
                db.run(
                    'INSERT INTO historico (manifestacao_id, evento, usuario) VALUES (?, ?, ?)',
                    [req.params.id, `Encaminhado para: ${responsavel}`, 'Admin']
                );
            }
            
            // Buscar manifestação atualizada
            db.get('SELECT * FROM manifestacoes WHERE id = ?', [req.params.id], (err, row) => {
                if (err) {
                    res.status(500).json({ error: err.message });
                } else {
                    res.json(row);
                }
            });
        }
    });
});

// DELETE - Excluir manifestação
app.delete('/api/manifestacoes/:id', (req, res) => {
    db.run('DELETE FROM manifestacoes WHERE id = ?', [req.params.id], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
        } else if (this.changes === 0) {
            res.status(404).json({ error: 'Manifestação não encontrada' });
        } else {
            // Deletar histórico relacionado
            db.run('DELETE FROM historico WHERE manifestacao_id = ?', [req.params.id]);
            res.json({ message: 'Manifestação excluída com sucesso', id: req.params.id });
        }
    });
});

// GET - Estatísticas
app.get('/api/estatisticas', (req, res) => {
    const stats = {};

    // Total de manifestações
    db.get('SELECT COUNT(*) as total FROM manifestacoes', (err, row) => {
        stats.total = row.total;

        // Por status
        db.all(`
            SELECT status, COUNT(*) as count 
            FROM manifestacoes 
            GROUP BY status
        `, (err, rows) => {
            stats.porStatus = rows.reduce((acc, row) => {
                acc[row.status] = row.count;
                return acc;
            }, {});

            // Por tipo
            db.all(`
                SELECT tipo, COUNT(*) as count 
                FROM manifestacoes 
                GROUP BY tipo
            `, (err, rows) => {
                stats.porTipo = rows.reduce((acc, row) => {
                    acc[row.tipo] = row.count;
                    return acc;
                }, {});

                // Por categoria
                db.all(`
                    SELECT categoria, COUNT(*) as count 
                    FROM manifestacoes 
                    GROUP BY categoria
                `, (err, rows) => {
                    stats.porCategoria = rows.reduce((acc, row) => {
                        acc[row.categoria] = row.count;
                        return acc;
                    }, {});

                    // Por canal
                    db.all(`
                        SELECT canal, COUNT(*) as count 
                        FROM manifestacoes 
                        GROUP BY canal
                    `, (err, rows) => {
                        stats.porCanal = rows.reduce((acc, row) => {
                            acc[row.canal] = row.count;
                            return acc;
                        }, {});

                        res.json(stats);
                    });
                });
            });
        });
    });
});

// GET - Histórico de uma manifestação
app.get('/api/manifestacoes/:id/historico', (req, res) => {
    db.all(
        'SELECT * FROM historico WHERE manifestacao_id = ? ORDER BY data DESC',
        [req.params.id],
        (err, rows) => {
            if (err) {
                res.status(500).json({ error: err.message });
            } else {
                res.json(rows);
            }
        }
    );
});

// Servir o frontend
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log('');
    console.log('🚀 ========================================');
    console.log('🎉 SERVIDOR OUVIDORIA DIGITAL INICIADO!');
    console.log('🚀 ========================================');
    console.log('');
    console.log(`📍 Servidor rodando em: http://localhost:${PORT}`);
    console.log(`📊 API disponível em: http://localhost:${PORT}/api`);
    console.log(`💾 Banco de dados: ouvidoria.db (SQLite)`);
    console.log('');
    console.log('📡 Endpoints disponíveis:');
    console.log('   GET    /api/manifestacoes');
    console.log('   GET    /api/manifestacoes/:id');
    console.log('   POST   /api/manifestacoes');
    console.log('   PUT    /api/manifestacoes/:id');
    console.log('   DELETE /api/manifestacoes/:id');
    console.log('   GET    /api/estatisticas');
    console.log('');
    console.log('💡 Pressione Ctrl+C para parar o servidor');
    console.log('========================================');
});

// Fechar banco ao encerrar
process.on('SIGINT', () => {
    db.close((err) => {
        if (err) {
            console.error(err.message);
        }
        console.log('\n👋 Servidor encerrado. Banco de dados fechado.');
        process.exit(0);
    });
});
