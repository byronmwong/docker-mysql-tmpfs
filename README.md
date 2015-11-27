# MySQL tmpfs Docker image

## How to use

```
docker run --name tmp-mysql --privileged -d nicokaiser/mysql-tmpfs
```

## Environment Variables

### `MYSQL_TMPFS_SIZE`

The size of the tmpfs partition, in MB (default: 256)

### `MYSQL_INIT_FILE`

Location of the MySQL init-file. Can be mounted via the -v option:

```
mkdir mysql-init
cat > ./mysql-init/init.sql <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY 'mysecret' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;

CREATE DATABASE mydatabase ;
...
EOSQL
docker run --name tmp-mysql --privileged -p 3306:3306 -v $(pwd)/mysql-init:/mysql-init -e MYSQL_INIT_FILE=/mysql-init/init.sql -d nicokaiser/mysql-tmpfs
```

If no MYSQL_INIT_FILE is given, a default one (root user, no password) is created.
