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

# Solicita o diretório onde os backups estão armazenados
read -p "Digite o diretório onde os backups estão armazenados (padrão: ~/backups): " BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-~/backups}

# Verifica se o diretório existe e contém backups
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ O diretório '$BACKUP_DIR' não existe!"
    exit 1
fi

# Lista os backups disponíveis
BACKUPS=($(ls -1 "$BACKUP_DIR" | grep -E '\.sql$|\.dump$' | sort -r))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "❌ Nenhum backup encontrado em '$BACKUP_DIR'!"
    exit 1
fi

# Exibe a lista de backups disponíveis
echo "Selecione os backups que deseja restaurar (separe os números por espaço):"
for i in "${!BACKUPS[@]}"; do
    printf "%3d) %s\n" $((i+1)) "${BACKUPS[$i]}"
done

# Lê a seleção do usuário
read -p "Opções: " -a selections

# Verifica se alguma seleção foi feita
if [ ${#selections[@]} -eq 0 ]; then
    echo "Nenhuma opção selecionada. Saindo..."
    exit 1
fi

# Itera sobre as seleções e realiza o restore
for sel in "${selections[@]}"; do
    # Verifica se a seleção é um número válido
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || [ "$sel" -lt 1 ] || [ "$sel" -gt "${#BACKUPS[@]}" ]; then
        echo "Seleção inválida: $sel. Pulando..."
        continue
    fi

    BACKUP_FILE="${BACKUPS[$((sel-1))]}"

    # Obtém o nome do banco de dados a partir do nome do arquivo
    DB_NAME=$(echo "$BACKUP_FILE" | sed -E 's/_[0-9]+_[0-9]+\.sql$//')

    echo "🔄 Restaurando backup '$BACKUP_FILE' no banco '$DB_NAME'..."

    # Verifica se o banco existe
    DB_EXISTS=$(psql -U "$PGUSER" -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'")
    if [ "$DB_EXISTS" != "1" ]; then
        echo "⚠️ O banco '$DB_NAME' não existe. Criando..."
        createdb -U "$PGUSER" "$DB_NAME"
    fi

    # Executa o restore
    pg_restore -U "$PGUSER" -d "$DB_NAME" "$BACKUP_DIR/$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "✅ Restore do banco '$DB_NAME' concluído com sucesso!"
    else
        echo "❌ Erro ao restaurar o banco '$DB_NAME'!"
    fi
done

