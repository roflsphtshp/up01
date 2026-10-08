#!/bin/bash

set -e

PASSWORD='P@ssw0rd'

echo "=== Проверка авторизации FreeIPA ==="
klist >/dev/null 2>&1 || {
    echo "Ошибка: сначала выполните kinit admin"
    exit 1
}

echo "=== Создание групп ==="

ipa group-add sysadmins \
    --desc="Системные администраторы" 2>/dev/null || true

ipa group-add webadmins \
    --desc="Веб-администраторы" 2>/dev/null || true

ipa group-add clients \
    --desc="Клиенты" 2>/dev/null || true


echo "=== Создание sysadmin ==="

if ! ipa user-show sysadmin >/dev/null 2>&1; then
    printf '%s\n%s\n' "$PASSWORD" "$PASSWORD" | \
    ipa user-add sysadmin \
        --first="Системный" \
        --last="Администратор" \
        --password
fi

ipa group-add-member sysadmins --users=sysadmin 2>/dev/null || true


echo "=== Создание webadmin_1 ... webadmin_30 ==="

for i in $(seq 1 30); do
    USER="webadmin_$i"

    if ! ipa user-show "$USER" >/dev/null 2>&1; then
        echo "Создаём $USER"

        printf '%s\n%s\n' "$PASSWORD" "$PASSWORD" | \
        ipa user-add "$USER" \
            --first="Webadmin" \
            --last="$i" \
            --password
    else
        echo "$USER уже существует"
    fi

    ipa group-add-member webadmins \
        --users="$USER" 2>/dev/null || true
done


echo "=== Создание client_1 ... client_30 ==="

for i in $(seq 1 30); do
    USER="client_$i"

    if ! ipa user-show "$USER" >/dev/null 2>&1; then
        echo "Создаём $USER"

        printf '%s\n%s\n' "$PASSWORD" "$PASSWORD" | \
        ipa user-add "$USER" \
            --first="Client" \
            --last="$i" \
            --password
    else
        echo "$USER уже существует"
    fi

    ipa group-add-member clients \
        --users="$USER" 2>/dev/null || true
done


echo
echo "======================================"
echo "       ПРОВЕРКА РЕЗУЛЬТАТА"
echo "======================================"

echo
echo "--- sysadmins ---"
ipa group-show sysadmins

echo
echo "--- webadmins ---"
ipa group-show webadmins

echo
echo "--- clients ---"
ipa group-show clients

echo
echo "Готово."
