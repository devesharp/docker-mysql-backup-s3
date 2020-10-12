const args = require("args-parser")(process.argv);
const AWS = require('aws-sdk');
const fs = require('fs');
const del = require('del');

const spawnSync = require('child_process').spawnSync;
const moment = require('moment-timezone');

/**
 * --------------------------------
 * Backup do banco de dados
 * --------------------------------
 */
let folder = moment().tz('America/Sao_Paulo').format('YYYY-MM-DD');
let date = moment().tz('America/Sao_Paulo').format('YYYY-MM-DD__hh-mm-ss');
spawnSync('zip',['-r', '-P', args.PASSWORD_ZIP, '/backup/mysql_'+date+'.zip', '/mysql.sql']).toString();

/**
 * --------------------------------
 * Salvar no S3
 * --------------------------------
 */
const BUCKET = args.AWS_BUCKET;
const REGION = args.AWS_REGION;
const ACCESS_KEY = args.AWS_ACCESS_KEY;
const SECRET_KEY = args.AWS_SECRET_KEY;

AWS.config.update({
    accessKeyId: ACCESS_KEY,
    secretAccessKey: SECRET_KEY,
    region: REGION
})

const s3 = new AWS.S3();

s3.putObject({
    Bucket: BUCKET,
    Body: fs.readFileSync('/backup/mysql_'+date+'.zip'),
    Key: folder + '/mysql_'+args.MYSQL_DB+'_'+date+'.zip'
})
    .promise()
    .then(response => {
        console.log(`Backup mysql realizado com sucesso! - `, response);
        
        // Deletar arquivo
        // del.sync('/backup/mysql_'+date+'.zip', {
        //     force: true
        // });
    })
    .catch(err => {
        // Deletar arquivo
        // del.sync('/backup/mysql_'+date+'.zip');
        console.log(`Erro ao realizar backup do mysql - `, err)
    });

