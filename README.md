
# **Backup e Restore de Banco de Dados PostgreSQL**

Este repositório contém dois scripts para gerenciar backups e restores de bancos de dados PostgreSQL. O primeiro script permite fazer o backup de bancos de dados, e o segundo permite restaurar esses backups.

## **1. backup_postgresql.sh** - **Script de Backup**

### **Descrição**
Este script realiza o backup de bancos de dados PostgreSQL. Ele conecta-se ao servidor PostgreSQL, lista todos os bancos de dados (exceto os modelos), exibe uma lista para o usuário selecionar quais bancos ele deseja fazer backup, e então gera o backup dos bancos selecionados em um diretório de sua escolha.

### **Funcionalidades**
- **Conexão com PostgreSQL**: O script pede as credenciais de usuário e senha para se conectar ao servidor PostgreSQL e valida a conexão.
- **Seleção de Bancos**: O script exibe todos os bancos de dados e permite ao usuário selecionar quais deseja fazer backup.
- **Backup de Bancos**: Os backups são salvos em arquivos no diretório especificado pelo usuário. O nome do arquivo contém o nome do banco e um timestamp para facilitar a identificação.

### **Como Usar**
1. **Baixe o script**:
    - Salve o arquivo como `backup_postgresql.sh`.

2. **Torne o script executável**:
    ```bash
    chmod +x backup_postgresql.sh
    ```

3. **Execute o script**:
    ```bash
    ./backup_postgresql.sh
    ```

4. **Siga as instruções**:
    - O script pedirá as credenciais do PostgreSQL.
    - Você será solicitado a escolher um diretório para salvar os backups.
    - O script listará os bancos de dados e você poderá selecionar quais deseja fazer backup.
    - O backup será realizado e salvo no diretório escolhido.

### **Exemplo de Saída**
```bash
Digite o nome de usuário do PostgreSQL: postgres
Digite a senha do PostgreSQL:
Digite o diretório onde deseja salvar os backups (padrão: ~/backups): /tmp/backups
Selecione os bancos de dados que deseja fazer backup (separe os números por espaço):
  1) stock_side_dev | 21 (MB)
  2) ticketei_dev | 8179 (kB)
Opções: 1 2
```

---

## **2. restore_postgresql.sh** - **Script de Restore**

### **Descrição**
Este script realiza a restauração de backups previamente gerados. Ele lista os backups disponíveis no diretório especificado, permite que o usuário selecione quais backups deseja restaurar e então restaura o banco de dados correspondente a cada backup.

### **Funcionalidades**
- **Conexão com PostgreSQL**: O script pede as credenciais de usuário e senha para se conectar ao servidor PostgreSQL e valida a conexão.
- **Seleção de Backups**: O script exibe todos os arquivos de backup disponíveis e permite ao usuário selecionar quais deseja restaurar.
- **Restauração de Bancos**: O script verifica se o banco de dados existe. Caso contrário, ele cria o banco antes de restaurar o backup.

### **Como Usar**
1. **Baixe o script**:
    - Salve o arquivo como `restore_postgresql.sh`.

2. **Torne o script executável**:
    ```bash
    chmod +x restore_postgresql.sh
    ```

3. **Execute o script**:
    ```bash
    ./restore_postgresql.sh
    ```

4. **Siga as instruções**:
    - O script pedirá as credenciais do PostgreSQL.
    - Você será solicitado a escolher o diretório onde os backups estão armazenados.
    - O script listará os backups disponíveis e você poderá selecionar quais deseja restaurar.
    - O restore será realizado para os bancos de dados correspondentes.

### **Exemplo de Saída**
```bash
Digite o nome de usuário do PostgreSQL: postgres
Digite a senha do PostgreSQL:
Digite o diretório onde os backups estão armazenados (padrão: ~/backups): /tmp/backups
Selecione os backups que deseja restaurar (separe os números por espaço):
  1) stock_side_dev_20250206_193815.sql
Opções: 1
```

---

## **Considerações Finais**

- Ambos os scripts exigem que o PostgreSQL esteja corretamente configurado e que você tenha permissões suficientes para realizar backups e restores.
- Para ambos os scripts, o usuário deve fornecer as credenciais de login (usuário e senha do PostgreSQL).
- O diretório de destino para os backups ou de origem para os restores pode ser alterado a qualquer momento, e a verificação de conexão com o servidor PostgreSQL é realizada para evitar erros.
