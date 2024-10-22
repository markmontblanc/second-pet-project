# Вказуємо базовий образ. Ми використовуємо Python 3.9, але ви можете вибрати іншу версію, якщо потрібно.
FROM python:3.9-slim

# Створюємо директорію для нашого додатку всередині контейнера
WORKDIR /app

# Копіюємо файл з вимогами в контейнер
COPY requirements.txt ./

# Встановлюємо залежності
RUN pip install --no-cache-dir -r requirements.txt

# Копіюємо весь код додатку в контейнер
COPY . .

ENV PYTHONUNBUFFERED=1


# Команда для запуску Django сервера
CMD ["gunicorn", "--bind", "0.0.0.0:8001", "backend_rds.wsgi:application"]
