<details>
<summary><b>Project creation</b></summary>

### Create virtual environment / Создать виртуальное окружение
Windows
```
python -m venv venv
```

Linux
```
python3 -m venv venv
```

### Activate virtual environment / Активация виртуального окружения
Windows
```
.\venv\Scripts\activate
```
Linux
```
source venv/bin/activate
```

### Installing libraries / Установка библиотек
```
python.exe -m pip install --upgrade pip
pip install Django
pip install python-dotenv
pip install psycopg2(меняем на psycopg2-binary)
```

### Create requirements.txt / создаем файл с зависимостями
```
pip freeze > requirements.txt
```

### Create project / Создать проект
```
django-admin startproject config .
```

### Create .env and .envtemplate file with data / Создайте файл .env с данными
```
SECRET_KEY= #take from settings.py
DEBUG=True
ALLOWED_HOSTS=*
```

### Add and change data in settings.py / добавьте и измените данные в settings.py
Add: / добавить
```
from dotenv import load_dotenv
import os

load_dotenv()
```
Change next values to: / изменить
```
SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG')
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS').split(',')

LANGUAGE_CODE = 'ru-Ru'
```

### Create db in pgadmin / Создать бд в pgadmin
with name mydb

### Create user in pgadmin / Создать юзера в pgadmin
```
CREATE USER new_user WITH PASSWORD 'new_user_password';
```

### Give user privileges to db / даем юзеру привелегии
```
GRANT ALL PRIVILEGES ON DATABASE mydb TO new_user;
```
or with / или с помощью(полезно давать конкретные разрешения)
```
GRANT CONNECT ON DATABASE mydb TO new_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE table_name TO new_user;
```

### Add the DATABASE environment variables in .env / добавляем данные по бд в файл .env
```
DB_NAME=mydb
DB_USER=new_user
DB_PASSWORD=new_user_password
DB_HOST=localhost
DB_PORT=5432
```
and add / change data for bd in settings.py / меняем данные по бд в settings.py
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST'),
        'PORT': os.environ.get('DB_PORT'),
    }
}
```

### Create first app / Создать первое приложение

```
python manage.py startapp firstapp
```

### Add app to settings.py -> INSTALLED_APPS / Добавить приложение в settings.py -> INSTALLED_APPS
```
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'firstapp',]
```

### Create user model in firstapp/models.py / Создаем модель юзера
```
from django.contrib.auth.models import AbstractUser


class CustomUser(AbstractUser):
    # age = models.IntegerField(blank=True, null=True)
    # city = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        verbose_name = "Пользователь"
        verbose_name_plural = "Пользователи"
```

### Add to settings.py auth user model / добавляем в settings.py модель юзера
```
AUTH_USER_MODEL = 'firstapp.CustomUser'
```

and make migrations / делаем миграции
```
python manage.py makemigrations
python manage.py migrate
```

### Create superuser for admin-panel / Создаем суперюзера
```
python manage.py createsuperuser
```
### Check admin panel / Проверяем админку
```
python manage.py runserver
```
go to http://127.0.0.1:8000/admin

### Add user model to django admin 
```
# firstapp/admin.py

from django.contrib import admin
from .models import CustomUser

admin.site.register(CustomUser)
```

### Adding functional / Добавляем функционал
```
1) Show next fields: / Отобразить поля в списке:
username,email,first_name,last_name.

2) Add search in fields / Добавить поиск по полям: 
emailfirst_name,last_name,username.

3) Add filters on fields / Добавить фильтры по полям: 
is_staff, is_active, is_superuser.

4) Hide field / Скрыть поле 
Password

5) Make immutable fields / Сделать поля неизменяемыми:
Last login, Date joined.

6) Add opportunity to change password from admin / Добавить возможность изменять пароль из Django admin.

```
Change code in firstapp/admin.py / Меняем код в firstapp/admin.py
```
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser


class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name')
    search_fields = ('email', 'first_name', 'last_name', 'username')
    list_filter = ('is_staff', 'is_active', 'is_superuser')
    exclude = ('password', )
    readonly_fields = ('last_login', 'date_joined')
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        (('Personal info'), {'fields': ('first_name', 'last_name', 'email')}),
        (('Permissions'), {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (('Important dates'), {'fields': ('last_login', 'date_joined')}),
    )
    ordering = ('email',)

    def get_fieldsets(self, request, obj=None):
        if not obj:
            return self.add_fieldsets
        return super().get_fieldsets(request, obj)

    def get_readonly_fields(self, request, obj=None):
        if obj:
            return self.readonly_fields + ('email', )
        return self.readonly_fields

    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)
        if 'password' in form.changed_data:
            obj.set_password(form.cleaned_data['password'])
            obj.save()

admin.site.register(CustomUser, CustomUserAdmin)
```

# Send to Github / Отправляем на гит
```
git init

git remote add origin "your github"

git add .

git commit -m "Your commit message here"

git push origin master

```
</details>

<details>
<summary><b>Deploy dockerfile, docker-compose</b></summary>

```
Договорились, что фронтенд предоставит мне образ, в котором будет установлен nginx, раздающий статические файлы и проксирующий запросы по /api, /admin и /static на мой контейнер.

Итого мне потребуется 4 контейнера:
Frontend — отдает статические файлы пользователю и по /api направляет запросы на контейнер с API.
API — наш бэкенд, должен слушать на 8000-м порту.
Миграции — контейнер, применяющий миграции при старте приложения. Это такой же контейнер, как и API, только выполняющий отдельную команду (python [manage.py](http://manage.py) migrate).
PostgreSQL — база данных.
```
### Создаем Dockerfile.frontend(не нужен, так как в докеркомпоуз пулим готовый образ)
```
# Используем образ, содержащий Nginx
FROM nginx:latest

# Копируем конфигурационный файл Nginx внутрь образа
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем статические файлы внутрь образа
COPY static/ /usr/share/nginx/html/static/

# Задаем переменную окружения API_URL
ENV API_URL=http://api:8000

# Открываем порт 80, чтобы Nginx мог слушать запросы
EXPOSE 80

# Запускаем Nginx
CMD ["nginx", "-g", "daemon off;"]
```
### Создаем Dockerfile.api
```
# Используем образ Python 3.10 slim
FROM python:3.10-slim

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y netcat
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY . .

# Открываем порт 8000, чтобы API мог слушать запросы
EXPOSE 8000

# Задаем переменную окружения DATABASE_URL
ENV DATABASE_URL=postgres://postgres:postgres@postgres:5432/postgres

# Запускаем приложение
CMD sh -c "python manage.py wait_for_db && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"

```
### Создаем Dockerfile.migrations
```
# Используем образ Python 3.10 slim
FROM python:3.10-slim

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y netcat
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY . .

# Задаем переменную окружения DATABASE_URL
ENV DATABASE_URL=postgres://postgres:postgres@postgres:5432/postgres

# Запускаем миграции
CMD sh -c "python manage.py wait_for_db && python manage.py migrate"

```
### Создаем Dockerfile.postgres

```
# Используем образ PostgreSQL
FROM postgres:latest

# Задаем переменные окружения для базы данных
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

# Копируем файл с инициализационными скриптами
COPY init.sql /docker-entrypoint-initdb.d/

# Открываем порт 5432, чтобы PostgreSQL мог слушать запросы
EXPOSE 5432
```

### Cоздаем файл init.sql со скриптами
```
Файл init.sql содержит SQL-скрипты, которые выполняются при инициализации базы данных. 
В этом файле вы можете создавать таблицы, добавлять данные и выполнять другие операции с базой данных.
```
```
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

INSERT INTO users (name, email) VALUES ('test 1', 'test1@mail.ru');
INSERT INTO users (name, email) VALUES ('test 2', 'test2@mail.ru');

```


### Проверяем корректную работу Dockerfiles
```
docker build -t apimyimage:latest -f Dockerfile.api .

docker run --rm -it myimage:latest

Подключаемся к запущенному контейнеру и проверяем наличие установленных в нем пакетов:
docker exec -it <container-id> bash

Проверка логов
docker logs <container-id>
```
### Создаем файл docker-compose.yml, который объединит все контейнеры в единую сеть
```
version: '3.8'

services:
  frontend:
    image: sermalenk/skypro-front:lesson-37
    ports:
      - "80:80"
    depends_on:
      - api
    restart: unless-stopped

  api:
    build:
      context: .
      dockerfile: Dockerfile.api
    ports:
      - "8000:8000"
    depends_on:
      - postgres
    environment:
      - DB_USER=myuser
      - DB_PASSWORD=mypassword
      - DB_NAME=mydatabase
      - DB_HOST=postgres
      - DB_PORT=5432
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

  migrations:
    build:
      context: .
      dockerfile: Dockerfile.migrations
    depends_on:
      - postgres
    environment:
      - DB_USER=myuser
      - DB_PASSWORD=mypassword
      - DB_NAME=mydatabase
      - DB_HOST=postgres
      - DB_PORT=5432
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

  postgres:
    build:
      context: .
      dockerfile: Dockerfile.postgres
    environment:
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
      - POSTGRES_DB=mydatabase
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

networks:
  backend:

volumes:
  postgres-data:
```
### Проверяем docker-compose:
```
docker-compose up -d
Получил ошибку с psycopg - поменял в requirements.txt на psycopg2-binary
```
</details>