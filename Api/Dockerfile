FROM python:3.12

ENV PYTHONUNBUFFERED 1

RUN mkdir /app

WORKDIR /app

# Kopiujemy plik requirements.txt do katalogu roboczego
COPY requirements.txt /app/

# Instalujemy zależności
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Kopiujemy resztę kodu aplikacji do katalogu roboczego
COPY . /app/

# Uruchamiamy migracje i serwer Django
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
