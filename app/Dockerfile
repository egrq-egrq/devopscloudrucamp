FROM python:3.11.4-alpine3.17

ENV BUILD_DEPS="build-base" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY requirements.txt /app/

RUN apk --no-cache --virtual .build-deps add $BUILD_DEPS \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

COPY . /app/

EXPOSE 8000

ENV HOSTNAME=77.com \
    AUTHOR=egrq.devops@gmail.com \
    UUID=3b2bc4ef-5d82-4d63-98f4-0b9fe7ca548b

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]
