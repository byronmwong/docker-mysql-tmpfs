#!/bin/bash
set -e

DATADIR='/var/lib/mysql'

if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

if [ "${1%_safe}" = 'mysqld' ]; then
	echo 'Running mysql_install_db ...'
	mysql_install_db
	echo 'Finished mysql_install_db'

	if [ -e "$MYSQL_INIT_FILE" ]; then
		echo 'Setting init file ...'

		# Allow user to provide their own init file
		# This has to include all privileges, users and databases,
		# no further SQL is being executed if this file is present

		set -- "$@" --init-file="$MYSQL_INIT_FILE"
	else
		echo 'Creating default init file ...'
		tempSqlFile='/tmp/mysql-init.sql'
		cat > "$tempSqlFile" <<-EOSQL
			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
		EOSQL

		if [ "$MYSQL_DATABASE" ]; then
			echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
		fi
		
		if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
			echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$tempSqlFile"
			
			if [ "$MYSQL_DATABASE" ]; then
				echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
			fi
		fi

		echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"

		set -- "$@" --init-file="$tempSqlFile"
	fi
fi

chown -R mysql:mysql "$DATADIR"
exec "$@"
