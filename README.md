## Configuración

Debemos editar el archivo ```.env``` y ajustar los valores a nuestro escenario.

La mayoría de los valores pueden quedar como están, pero debemos asegurarnos que el valor para ```HOST_IP``` refleje la dirección ip que pensamos exponer a los clientes.

## Agregar un esclavo

Agremos una linea en ```.env``` para definir el puerto en el que escuchará ese nodo
```
SLAVEx_PORT=6385
```

Editamos ```docker-compose.yml``` y agregamos una sección similar a la siguiente
```yaml
redis-slave-x:
  image: vision/redis
  container_name: redis-slave-x
  restart: on-failure:5
  ports:
    - "${SLAVEx_PORT}:6379"
  environment:
    - SLAVE=true
    - HOST_IP=${HOST_IP}
    - PORT=${SLAVEx_PORT}
    - MASTER_PORT=${MASTER_PORT}
  secrets:
    - redis-auth
  links:
    - redis-master
```
Nos aseguramos de especificar la variable con el valor del puerto que acabamos de crear en ```ports``` y en la variable de entorno ```PORT``` en la sección ```environment```

## Agregar un sentinela

Agremos una linea en ```.env``` para definir el puerto en el que escuchará el sentinela.
```
SENTINELx_PORT=26385
```

Editamos ```docker-compose.yml``` y agregamos una sección similar a la siguiente
```yaml
redis-sentinel-x:
  image: vision/redis
  container_name: redis-sentinel-x
  restart: on-failure:5
  ports:
    - "${SENTINELx_PORT}:26379"
  environment:
    - SENTINEL=true
    - HOST_IP=${HOST_IP}
    - PORT=${SENTINELx_PORT}
    - MASTER_PORT=${MASTER_PORT}
    - SENTINEL_QUORUM=2
    - SENTINEL_DOWN_AFTER=1000
    - SENTINEL_FAILOVER=1000
    secrets:
      - redis-auth
  links:
    - redis-master
```
Nos aseguramos de especificar la variable con el valor del puerto que acabamos de crear en ```ports``` y en la variable de entorno ```PORT``` en la sección ```environment```

### Inspiración:
An example setup for using Redis Sentinel with Docker Compose.  
See my blog post for more information and an explanation: https://blog.alexseifert.com/2016/11/14/using-redis-sentinel-with-docker-compose/
