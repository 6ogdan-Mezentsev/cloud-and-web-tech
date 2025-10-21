# ---------------- BAD-PRACTICE
# 1. Используем слишком тяжёлый базовый образ Ubuntu
FROM ubuntu:latest  

# 2. Устанавливаем все пакеты вручную и не чистим кеш apt
RUN apt update && apt install -y nodejs npm  

WORKDIR /lab2

COPY . .

# 3. Устанавливаем зависимости от root-пользователя
RUN npm install  

# 4. Не указываем EXPOSE (порт, который слушает контейнер)
CMD ["node", "index.js"]


# ---------------- BEST-PRACTICE
# 1. Используем легкий базовый образ Node.js, а не Ubuntu
FROM node:18-alpine

WORKDIR /lab2

# 2. Копируем только package.json перед установкой зависимостей
COPY package.json ./

# 3. Устанавливаем зависимости
RUN npm install --production

COPY . .

# 4. Указываем порт, который будет слушать контейнер
EXPOSE 8001

CMD ["node", "index.js"]

