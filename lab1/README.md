# 1 лабораторная работа "DevOps" - настройка Nginx

## Задание

1) Настроить nginx для работы по HTTPS с использованием самоподписанных SLL-сертификатов.
2) Настроить перенаправление всех HTTP-запросов (порт 80) на HTTPS (порт 443).
3) С помощью конфигурации веб-сервера организовать работу двух независимых проектов на одном сервере. И для удобства разделить их отдельными вертуальными хостами.
4) Использовть alias'ы для доступа к некоторым файлам проекта.

## Ход работы

Начнем с установки самого Nginx:
для этого в терминале macOS запускаем данную команды
```bash
brew install nginx
```

Теперь разберемся с проектами, которые будут запускаться на одном сервере(нашем ноуте), но будут доступны на разных доменах:

1) В роли первого проекта будет выступать простой API(с одной ручкой на GET-запрос) на Node.js, который поднимает сервер на порту 8001 и по адресу `/api/hello` возвращает JSON-ответ с сообщением.\
API будет доступен по домену `api.local` и отвечать на запросы к `/api/hello`.
2) А вторым проектом будет статическая HTML-страница с подключёнными стилями и скриптом, который обращается к API и выводит полученный текст на страницу.\
   Фронт будет доступен по доменму `front.local`.

Так как мы хотим перенаправлять все HTTP-запросы на HTTPS, то нам неообходимо создать самоподписанные сертификаты (без них HTTPS не поднимется). 
Генерируем их с помощью утилиты **mkcert** в новой директории `/etc/nginx/selfsigned`, где будут храниться сертификаты:
```bash
mkdir -p /etc/nginx/selfsigned

cd /etc/nginx/selfsigned

mkcert front.local
mkcert api.local
```
В результате в текущей директории были сгенерированы файлы:
`front.local.pem` и `front.local-key.pem` для домена `front.local`, `api.local.pem` и `api.local-key.pem` для домена `api.local`.

Теперь необходимы файлы с конфишами для наших виртуальных хостов, они будут находиться в `/opt/homebrew/etc/nginx/sites-enabled`:
1. Для начала напишем конфиг для редиректа `redirect.conf`(пояснения к коду в комментах):
```bash
server {
  listen 80;  # сервер слушает порт 80 (HTTP)
  listen [::]:80;  # то же самое, но для IPv6.
  server_name _;  # работате для любых домены
  return 301 https://$host$request_uri;  # при любом запросе возвращается редирект 301 на тот же самый адрес, но уже по протоколу HTTPS.
}
```
2. Теперь разберем `api.local.conf`:

При тесте работы конфига возникла ошибка, так как при попытке обратиться к API на стороне фронта `fetch('https://api.local/api/hello')` возникала ошибка:

`Access to fetch at 'https://api.local/api/hello' from origin 'https://front.local' has been blocked by CORS policy`

это происходит потому что браузер считает это запросом с другого домена (cross-origin). По умолчанию такие запросы блокируются политикой безопасности браузера (CORS error).\
Поэтому мы явно разрешаем запросы от `https://front.local` в блоке `map $http_origin $cors_ok` с помощью флага(0/1)
```bash
map $http_origin $cors_ok {
  default 0;
  "https://front.local" 1;
}

server {
  listen 443 ssl;  # сервер слушает HTTPS-порт 443
  listen [::]:443 ssl; 
  http2 on;  # включаем поддержку протокола HTTP2
  server_name api.local;  # этот хост отвечает только за домен api.local

  # указываем пути для созданных сертификатов
  ssl_certificate     /opt/homebrew/etc/nginx/selfsigned/api.local.pem;
  ssl_certificate_key /opt/homebrew/etc/nginx/selfsigned/api.local-key.pem;
  ssl_protocols       TLSv1.2 TLSv1.3;

  set $cors_origin "";
  if ($cors_ok = 1) { set $cors_origin $http_origin; }

  # для CORS сразу возвращается 204 No Content с нужными заголовками
  location / {
    if ($request_method = OPTIONS) {
      add_header Access-Control-Allow-Origin  $cors_origin always;
      add_header Access-Control-Allow-Methods "GET,POST,PUT,PATCH,DELETE,OPTIONS" always;
      add_header Access-Control-Allow-Headers "Content-Type,Authorization" always;
      add_header Access-Control-Max-Age 86400 always;
      return 204;
    }

    # Все остальные запросы перенаправляются на локальный Node.js сервер (127.0.0.1:8001)
    proxy_pass http://127.0.0.1:8001/;
    proxy_http_version 1.1;

    # Передаются важные заголовки (IP клиента, протокол, Host).
    proxy_set_header Host              $host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    # Возвращается CORS-заголовок, чтобы фронтенд (front.local) мог обращаться к API
    add_header Access-Control-Allow-Origin $cors_origin always;
    add_header Vary Origin always;
  }
}
```

3. И последний конфиг `front.local.conf`:
```bash
server {
  # тут все также сервер слушает HTTPS-порт 443 и отвечает только за домен front.local
  listen 443 ssl;  
  listen [::]:443 ssl;
  http2 on;
  server_name front.local;

  # также указываем пути для созданных сертификатов
  ssl_certificate     /opt/homebrew/var/log/nginx/front.local.pem;
  ssl_certificate_key /opt/homebrew/var/log/nginx/front.local-key.pem;
  ssl_protocols       TLSv1.2 TLSv1.3;

  
  root  /Users/6ogdanmezentsev/Desktop/oblaka/lab1/pr2;  # указываем корневую директорию проекта
  index index.html;  #  файл, который будет возвращаться по умолчанию, если запрашивается директория

  location = / { try_files /index.html =404; }  # nginx пытается отдать index.html по '/'. Если файла нет – вернёт 404 Not Found

  # блок для всех запросов к /static/...
  location /static/ {
    alias /Users/6ogdanmezentsev/Desktop/oblaka/lab1/pr2/static;  # указываем фактическую директорию, откуда отдавать файлы
  }

  # передаем базовые заголовки для безопасности
  add_header X-Content-Type-Options nosniff;
  add_header X-Frame-Options SAMEORIGIN;
}
```

Теперь, когда конфиги для ридиректа на HTTPS и двух виртуальных доменов `api.local` и `front.local` лежат в папке `/opt/homebrew/etc/nginx/sites-enabled`, нам необходимо включить эти файлы .conf в основной файл конфигурации nginx (`/opt/homebrew/etc/nginx/nginx.conf`)\
Для этого в `nginx.conf` в блоке `htttp {}` добавляем `include sites-enabled/*.conf;`\
Теперь nginx видит конфиги для наших виртуальных доменов и https


