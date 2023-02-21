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
pip install psycopg2
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