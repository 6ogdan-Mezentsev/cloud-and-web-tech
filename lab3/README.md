# Лабораторная работа №3

## Задание:
- Написать “плохой” CI/CD файл, который работает, но в нем есть не менее трех “bad practices” по написанию CI/CD
- Написать “хороший” CI/CD, в котором эти плохие практики исправлены
- В Readme описать каждую из плохих практик в плохом файле, почему она плохая и как в хорошем она была исправлена, как исправление повлияло на результат
- Прочитать историю про Васю (она быстрая, забавная и того стоит): https://habr.com/ru/articles/689234/
- Написать обычный отчет себе на гитхаб

## Решение:
1. **Деплой на любой push**
```
on:
  push:
    branches:
      - "*"
```
Деплой запускается на любой push, включая feature-ветки и тестовые коммиты

Исправлено на:
```
on:
  push:
    branches:
      - main
```
Деплой только из основной (production) ветки

2. **Секретные переменные**
```
env:
  DOCKERHUB_USER: your_dockerhub_login
  DOCKERHUB_PASSWORD: your_dockerhub_password
  IMAGE_NAME: your_dockerhub_login/express-lab2:latest
  SSH_HOST: 1.2.3.4
  SSH_USER: root
  SSH_PASSWORD: rootpassword
```
Секретные переменные хранятся прямо в YAML файле

Исправлено на:
```
- name: Login to Docker Hub
  uses: docker/login-action@v2
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```
Использование GitHub Secrets для хранения секретных данных

3. **Отсутствие полноценного тестового шага**
```
- name: Run container for test
  run: |
    docker run -d -p 8001:8001 --name test_container $IMAGE_NAME
    sleep 5
    curl http://localhost:8001/api/hello
    docker rm -f test_container
```
Тест не проверяет HTTP статус и не валидирует ответ

Исправлено на:
```
- name: Run test
  run: |
    sleep 5
    STATUS=$(curl -s -o response.json -w "%{http_code}" http://localhost:8001/api/hello)
    cat response.json
    [ "$STATUS" -eq 200 ]
    grep -q "Приветули" response.json
```
Тест проверяет доступность ручки API и корректность ответа

## Результат работы CI/CD
1. Отображаются пайплайны во вкладке Actions
<img width="2680" height="678" alt="image" src="https://github.com/user-attachments/assets/23122c2c-cfd6-4cdc-a8b5-a0fdedb71a03" />
2. Отображаются джобы внутри пайплайнов
<img width="3456" height="2234" alt="image" src="https://github.com/user-attachments/assets/05b4ecae-95bb-489c-99ef-09c398c71b67" />
3. Корректно работает ручка на удаленном сервере
<img width="3456" height="2234" alt="image" src="https://github.com/user-attachments/assets/6a984b7c-d285-472d-a6eb-ecf184bad0e1" />


