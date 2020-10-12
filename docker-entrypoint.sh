echo '';
echo '---------------------------------------';
echo 'Backup Mysql iniciado em: ' + $(date +%Y-%m-%d_%H-%M-%S);
db_size=$(mysql   -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} \
    --silent \
    --skip-column-names \
    -e "SELECT ROUND(SUM(data_length) / 1024 / 1024, 0) \
        FROM information_schema.TABLES \
        WHERE table_schema='$MYSQL_DB';")
mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --single-transaction --order-by-primary --compress ${MYSQL_DB} | pv --progress --size "$db_size"m > /mysql.sql
echo 'Realizando upload na S3';
node index.js \
    --AWS_BUCKET=${AWS_BUCKET} \
    --AWS_REGION=${AWS_REGION} \
    --MYSQL_DB=${MYSQL_DB} \
    --AWS_ACCESS_KEY=${AWS_ACCESS_KEY} \
    --AWS_SECRET_KEY=${AWS_SECRET_KEY} \
    --PASSWORD_ZIP=${PASSWORD_ZIP}
echo 'Backup Mysql finalizado em: ' + $(date +%Y-%m-%d_%H-%M-%S);
echo '---------------------------------------';
echo '';