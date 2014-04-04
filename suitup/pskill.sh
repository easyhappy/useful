#!/bin/sh

search=$1
ps aux | grep $search | awk '{print $0}'

result=`ps aux | grep $search | awk '{print $2}'`

echo '------------------------'
number=1
for i in $result
do
 echo $number $i
 number=`expr $number + 1`
done

echo '输入 number号, 杀死进程:'
read num

number=1
for i in $result
do
 if [ "$number" = "$num" ]
 then
  kill -9 $i
  echo '已杀死进程: ' $i
 fi
 number=`expr $number + 1`
done
