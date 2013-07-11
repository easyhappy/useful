#!/bin/bash
#Created from mksh on 2012年 08月 27日 星期一 07:24:28 CST
#Description: 
#  建立天际Rails项目开发环境
#Usage:
#  settj <where_you_put_railsprj>
#Test on: Ubuntu 12.04 passed

#==config your info here
mysql_root_pwd=andy120  #'' for empty?
tj_rails_web_repo=git@211.151.73.231:tianjicom  #make sure has upload your ssh pubkey to admin #TODO

#Required: git + ruby(bundler gem)
! which git >/dev/null && sudo apt-get install git-core && echo ==Installing git ...
! which ruby >/dev/null && echo ==Install ruby and bunlder gem firstly! && exit 1 

if [ ! "$1" ];then
  tjweb=~/dev/tianji
else
  tjweb=`readlink -f $1`
fi
tjweb=$tjweb/tianjicom
[ ! -d $tjweb ] && mkdir -p $tjweb && git clone $tj_rails_web_repo $tjweb
echo ==Using rails: $tjweb ...

#check redis and mongo? #TODO improve
! which mongod >/dev/null && echo ==Install MongoDB... && sudo apt-get install mongodb-server
! which redis-server >/dev/null && echo ==Install redis server... && sudo apt-get install redis-server
! which mysqld >/dev/null && echo ==Install mysql server ... && sudo apt-get install mysql-server

tjuser=`mysql -uroot -p$mysql_root_pwd -sN -e "use mysql; select user from user where user='tianji'"`
[ ! "$tjuser" ] && mysql -uroot -p$mysql_root_pwd -sN -e "grant all privileges on tianji.* to 'tianji'@localhost identified by 'tianji';" && echo ==Create a db user: tianji  ... || echo ==Has found tjuser: $tjuser, use it ...
#TODO check whether existed?
mysql -uroot  -p$mysql_root_pwd -sN -e "create database if not exists tianji DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" && echo ==Create tianji database ...

echo ==Issue rails processes, you can check log files in log/ ...
flag_file=log/mysqldb_migrated.log
[ ! -e $tjweb/$flag_file ] && (cd $tjweb && bundle install && rake db:migrate && touch $flag_file && echo mysql migrating ...) || echo ==Has run migrated ...

flag_file=log/mysqldb_seeded.log
[ ! -e $tjweb/$flag_file ] && (cd $tjweb && rake db:seed && touch $flag_file && echo db seeding ...) || echo ==Has run seeded ...

flag_file=log/mongo_indexed.log
[ ! -e $tjweb/$flag_file ] && (cd $tjweb && rake db:mongoid:create_indexes && touch $flag_file && echo mongo create indexing ...) || echo ==Has run mongo indexed ...

echo Congratulations! You have get tianji rails env stated, enjoy yourself ...
