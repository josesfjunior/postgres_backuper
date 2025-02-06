#!/bin/bash

# Função para testar a conexão com o PostgreSQL
test_connection() {
    PGPASSWORD="$1" psql -U "$2" -d postgres -c "SELECT 1;" &>/dev/null
    return $? 
}

# Solicita credenciais e valida conexão
while true; do
    read -p "Digite o nome de usuário do PostgreSQL: " PGUSER
    read -s -p "Digite a senha do PostgreSQL: " PGPASSWORD
    echo

    if test_connection "$PGPASSWORD" "$PGUSER"; then
        echo "✅ Conexão bem-sucedida!"
        break
    else
        echo "❌ Erro ao conectar! Verifique usuário/senha e tente novamente."
    fi
done

export PGPASSWORD

# Solicita o diretório de backup uma única vez
read -p "Digite o diretório onde deseja salvar os backups (padrão: ~/backups): " BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-~/backups}

# Cria o diretório, se não existir
mkdir -p "$BACKUP_DIR"

# Obtém a lista de bancos de dados com seus tamanhos, ordenados do maior para o menor
DATABASES=$(psql -U "$PGUSER" -d postgres -t -c "
    SELECT datname, pg_size_pretty(pg_database_size(datname)) 
    FROM pg_database 
    WHERE datistemplate = false 
    ORDER BY pg_database_size(datname) DESC;
")

# Converte a lista de bancos de dados em um array
IFS=$'\n' read -r -d '' -a DB_ARRAY <<< "$DATABASES"

# Função para exibir o menu e capturar as seleções
select_databases() {
    echo "Selecione os bancos de dados que deseja fazer backup (separe os números por espaço):"
    for i in "${!DB_ARRAY[@]}"; do
        DB_NAME=$(echo "${DB_ARRAY[$i]}" | awk '{print $1}')
        DB_SIZE=$(echo "${DB_ARRAY[$i]}" | awk '{$1=""; print $0}' | sed 's/^ *//')
        printf "%3d) %s (%s)\n" $((i+1)) "$DB_NAME" "$DB_SIZE"
    done

    read -p "Opções: " -a selections
}

# Chama a função para exibir o menu
select_databases

# Verifica se alguma seleção foi feita
if [ ${#selections[@]} -eq 0 ]; then
    echo "Nenhuma opção selecionada. Saindo..."
    exit 1
fi

# Itera sobre as seleções e realiza o backup
for sel in "${selections[@]}"; do
    # Verifica se a seleção é um número válido
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt "${#DB_ARRAY[@]}" ]; then
        echo "Seleção inválida: $sel. Pulando..."
        continue
    fi

    DB_INFO="${DB_ARRAY[$((sel-1))]}"
    DB_NAME=$(echo "$DB_INFO" | awk '{print $1}')  # Extraindo apenas o nome do banco

    # Define o nome do arquivo de backup
    BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"

    # Executa o backup
    pg_dump -U "$PGUSER" -d "$DB_NAME" -F c -f "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "✅ Backup do banco '$DB_NAME' salvo em: $BACKUP_FILE"
    else
        echo "❌ Erro ao fazer backup do banco '$DB_NAME'!"
    fi
done
