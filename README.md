## 1. Ansible playbook
### Установка зависимостей:
~~~
ansible-galaxy collection install -r ./playbook/requirements.yml
~~~

###  Укажите Ваш ansible_host
  - Инвентарь `./playbook/hosts.ini`

### Запуск плейбука
```
Usage: [-i INVENTORY] [-p PLAYBOOK] [-f CLOUDRU_PLAYBOOK_FORKS] [-t CLOUDRU_PLAYBOOK_TAGS]
```
```
Options:
    -i, --inventory    Specify the path to the Ansible inventory host file. The default is './hosts.ini'.
    -p, --playbook     Specify the path to the Ansible playbook file. The default is './playbook.yml'.
    -f, --forks        Specify the number of parallel processes to use while executing the playbook. This option is passed to the 'ansible-playbook' command using the '--forks' flag. The default is unset.
    -t, --tags         Run specific tasks that are tagged with the provided comma-separated list of tags. This option is passed to the 'ansible-playbook' command using the '--tags' flag. The default is unset.
    -h, --help         Display this help message.
```
- Скрипт создан для удобства запуска с помощью gitlab-runner 
- Он так же проверяет контрольную ноду на наличие ансибла, инвентаря и плейбука до запуска плейбука 
~~~
./playbook/prod.ansible-init.sh
~~~

## 2. Python3 web-app
### App
  - Приложение `./app/app.py`
  - Зависимости `./app/requirements.txt`:
```
    flask==2.0.1
    gunicorn==20.1.0
```
### Dockerfile
ENV для `./app/app.py` захардкожены в `./app/Dockerfile`

## Kubernetes manifest
1. Запуск приложения в Kubernetes в отдельном неймспейсе:
  - Задание: Создать пространства имен в Kubernetes с именем `cloudruspace`
  - Решение: Манифест `./manifest/app-deployment.yaml` создает пространство имен с помощью блока метаданных:
    ```
    kind: Namespace
    metadata:
      name: cloudruspace
    ```

2. Использование Deployment для управления развертыванием приложения с 3 репликами:
  - Задание: Создать Deployment с 3 репликами
  - Решение: Манифест `./manifest/app-deployment.yaml` устанавливает 3 реплики в блоке `spec` Deployment:
    ```
    spec:
      replicas: 3
    ```

3. Создание сервиса с типом `ClusterIP`:
  - Задание: Использовать сервис с типом `ClusterIP`
  - Решение: Манифест `./manifest/app-deployment.yaml` создает сервис со следующими спецификациями:
    ```
    spec:
      type: ClusterIP
    ```

4. Реализация readiness и liveness проб:
  - Задание: Добавить readiness и liveness пробы
  - Решение: Манифест `./manifest/app-deployment.yaml` определяет readiness и liveness пробы для контейнера `cloudruapp` с помощью следующих блоков в блоке `spec`:
    ```
    readinessProbe:
      httpGet:
        path: /id
        port: 8000
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /id
        port: 8000
      initialDelaySeconds: 5
      periodSeconds: 10
    ```

5. Установка уникального идентификатора пода в кластере, в котором запущено приложение, в переменную среды `UUID`:
  - Задание: Добавить переменную среды `UUID` с уникальным идентификатором пода
  - Решение: Манифест `./manifest/app-deployment.yaml` устанавливает переменную среды `UUID` для контейнера `cloudruapp` с использованием следующего блока в блоке `spec`:
    ```
    env:
    - name: UUID
      valueFrom:
        fieldRef:
          fieldPath: metadata.uid
    ```

## Helm chart
1. Запуск приложения с использованием переменных из файла values.yaml:
  - Задание: Через переменные в файле values.yaml задать имя образа, количество реплик и значение переменной AUTHOR
  - Решение: Файл `./helm/Values.yaml` содержит следующие значения:
     ```yaml
     image:
       repository: egrqdockerhub/cloudruapp
       tag: 1.0.0
       pullPolicy: IfNotPresent
     replicaCount: 3
     author: egrq.devops@gmail.com
     ```

2. Использование деплоймента для управления развертыванием приложения с заданным количеством реплик:
  - Задание: Создать деплоймент с заданным количеством реплик
  - Решение: Шаблон `./helm/templates/app-deployment.yaml` устанавливает значение реплик в блоке `spec` деплоймента:
     ```yaml
     spec:
       replicas: {{ .Values.replicaCount }}
     ```

3. Значение переменной AUTHOR:
  - Задание: Подставить значение в переменную AUTHOR
  - Решение: Шаблон `./helm/templates/app-deployment.yaml` устанавливает значение переменной AUTHOR для контейнера с использованием следующего блока в блоке `spec`:
     ```yaml
     env:
       - name: AUTHOR
         value: "{{ .Values.author }}"
     ```

4. Использование сервиса с типом `ClusterIP`:
  - Задание: Использовать сервис с типом `ClusterIP`
  - Решение: Шаблон `./helm/templates/app-service.yaml` создает сервис со следующими спецификациями:
     ```yaml
     spec:
       type: {{ .Values.service.type }}
     ```

5. Реализация readiness и liveness проб:
  - Задание: Добавить readiness и liveness пробы
  - Решение: Шаблон `./helm/templates/app-deployment.yaml` определяет readiness и liveness пробы для контейнера с использованием следующих блоков в блоке `spec`:
     ```yaml
     readinessProbe:
       httpGet:
         path: /id
         port: {{ .Values.service.port }}
       initialDelaySeconds: 5
       periodSeconds: 10
     livenessProbe:
       httpGet:
         path: /id
         port: {{ .Values.service.port }}
       initialDelaySeconds: 5
       periodSeconds: 10
     ```
