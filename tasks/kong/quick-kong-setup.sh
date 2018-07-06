#!/bin/ash
echo "TrustedUserCAKeys /etc/ssh/ca-user-certificate-key.pub" >> /etc/ssh/sshd_config
su postgres -c "/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data > /var/lib/postgresql/logfile 2>&1 &"

until psql --host=localhost --username=postgres postgres -w &>/dev/null
do
sleep 0.1
done

#until 'pg_isready' 2>/dev/null; do
#  >&2 echo "Postgres is unavailable - sleeping for 0.1 seconds"
#  sleep 0.1
#done

kong start -c /etc/kong/kong.conf

#while ! nc -z localhost 8001
#do 
#sleep 0.1
#done

rmqpwd=`cat /etc/rabbitmq | cut -d : -f 2 | awk '{$1=$1};1'`
ldapdpwd=`cat /etc/ldapd | cut -d : -f 2 | awk '{$1=$1};1'`
sed -i 's/rmq_user/admin.ideam/g' /home/ideam/share.py
sed -i 's/rmq_pwd/'$rmqpwd'/g' /home/ideam/share.py
sed -i 's/ldap_pwd/'$ldapdpwd'/g' /home/ideam/share.py
tmux new-session -d -s share 'python3.6 /home/ideam/share.py'
