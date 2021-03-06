#!/bin/bash

user="rmenezes"
pass="<senha>"
database="/mnt/c/Users/rmenezes/bin/database.csv"
cert="/mnt/c/Users/rmenezes/key"
log="/tmp/log.out"
logerr="/tmp/log.err"
tmp="/mnt/c/Users/rmenezes/tmp"
#certx="-i $cert/$key"
scpx="sshpass -p $pass scp"

f_checkFile(){
if [ ! -f $3 ]; then
	echo "Arquivo nao existe"
	exit 1
fi
}

if [ ! -f $database ]; then
	echo "Arquivo de banco nao existe."
	exit
fi

if [ -z "$1" ]; then
	#echo "Use: connect {\$1|--pesquisa,pesquisa,p \$1|\$1 --envia,envia,e <arquivo>|\$1 --recebe,recebe,r <arquivo>}"
	#echo "Destino \$1 nao informado."
	echo -e "Use: 
	connect \$1                               Conecta no host ou ip solicitado, estando no arquivo de banco de dados ou nao.

	connect --pesquisa|pesquisa|p \$1         Serve para realizar uma pesquisa no arquivo de banco de dados.

	connect \$1 --envia|envia|e <arquivo>     Serve para enviar um arquivo. Este estara disponivel no /tmp do destino.

	connect \$1 --recebe|recebe|r <arquivo>   Serve para receber um arquivo. Este estara disponivel em $tmp da origem.
	
	connect --editor|editor                   Server para editar o arquivo de connect.
	
	connect --database|database|d             Server para editar o arquivo de banco de dados."
	echo
	exit
fi

if [ $(cat /run/resolvconf/resolv.conf | grep "search tribanco.com.br" | wc -l) -eq 0 ]; then
	#echo "ssh: Could not resolve hostname: Temporary failure in name resolution"
	sudo chmod 777 /run/resolvconf/resolv.conf
	sudo echo "search tribanco.com.br" >> /run/resolvconf/resolv.conf
	sudo chmod 644 /run/resolvconf/resolv.conf
fi

if [ -z $(which textql) ]; then
	echo "Textql nao instalado ou nao encontrado."
	exit
else
	#clear
	if [ "$1" = "--pesquisa"  ] || [ "$1" = "pesquisa" ] || [ "$1" = "p" ]; then
		textql -output-dlm=' ' -header -sql "select id, (case when ip is null then host else ip end) as ip, \
			host, user, key, local, descricao from database where ip like '%$2%' or host like '%$2%' \
			or user like '%$2%' or key like '%$2%' or descricao like '%$2%' \
			or local like '%$2%' or id like '%$2%' order by id" $database > $log

		if [ ! -z "$4" ]; then
			cat $log | grep -i --color $3 | grep -i --color $4
		elif [ ! -z "$3" ]; then
			cat $log | grep -i --color $3
		else
			cat $log | grep -i --color $2
		fi

		exit
	fi

	if [ "$1" = "--editor" ] || [ "$1" = "editor" ]; then
		vim /mnt/c/Users/rmenezes/bin/connect
		exit
	fi

	if [ "$1" = "--database" ] || [ "$1" = "database" ] || [ "$1" = "d" ]; then
		vim /mnt/c/Users/rmenezes/bin/database.csv
		exit
	fi

	rm -f $log $logerr
	if [ ! -z $(textql -header -sql "select host from database where id like '$1'" $database) ]; then
		ip=$(textql -header -sql "select (case when ip is null then host else ip end) as ip from database where id like '$1'" $database)
		desc=$(textql -header -sql "select descricao from database where id like '$1'" $database)
		host=$(textql -header -sql "select host from database where id like '$1'" $database)
		user=$(textql -header -sql "select user from database where id like '$1'" $database)
		key=$(textql -header -sql "select key from database where id like '$1'" $database)
		id=$(textql -header -sql "select id from database where id like '$1'" $database)
		loc=$(textql -header -sql "select local from database where id like '$1'" $database)
		if [ ! -z "$key" ]; then
			if [ ! -f $cert/$key ]; then
				echo "Certificado nao encontrado."
				exit
			else
				cp $cert/$key /tmp
				chmod 600 /tmp/$key
				cert=/tmp
			fi
		#else
			#echo "A chave aqui e NULA!"
			#certx=""
		fi
		echo; echo -e "ID...: $id \nIP...: $ip \nHOST.: $host \nUSER.: $user \nKEY..: $key \nLOCAL: $loc"; echo
		if [ "$2" = "--envia" ] || [ "$2" = "envia" ] || [ "$2" = "e" ]; then
			#f_checkFile
			if [ -z $key ] || [ $key = "" ]; then
				sshpass -p $pass scp $3 $user@$ip:/tmp/
			else
				scp -i $cert/$key $3 $user@$ip:/tmp/
			fi
			cd $tmp
			elif [ "$2" = "--recebe" ] || [ "$2" = "recebe" ] || [ "$2" = "r" ]; then
				if [ -z $key ] || [ $key = "" ]; then
					sshpass -p $pass scp $user@$ip:$3 $tmp
				else
					scp -i $cert/$key $user@$ip:$3 $tmp
				fi
				cd $tmp
		else
			if [ "$loc" = "AWS" ]; then
				ssh -i $cert/$key $user@$ip -X
				rm -f $cert/$key
			else
				# TRIBANCO
				#sshpass -p $pass ssh $user@$ip -X
				if [ -z $user ]; then
					user="rmenezes"
				fi
				sshpass -p $pass ssh -Y -oStrictHostKeyChecking=no $user@$ip -X 2> $logerr
				if [ $(cat $logerr | grep "Permission denied" | wc -l) -eq 1 ]; then
					sshpass -p $pass ssh -q -Y -oStrictHostKeyChecking=no trbw2k'\'$user@$ip -X
				else
					cat $logerr
				fi
			fi
		fi
	else
		# Nao suprimir o banner -q no ssh/scp
		# SCP
		if [ "$2" = "--envia" ] || [ "$2" = "envia" ] || [ "$2" = "e" ]; then
			sshpass -p $pass scp -oStrictHostKeyChecking=no $3 $user@$1:/tmp/ 2> $logerr
			cd $tmp
			if [ $(cat $logerr | grep "Permission denied" | wc -l) -eq 1 ]; then
				sshpass -p $pass scp -oStrictHostKeyChecking=no $3 trbw2k'\'$user@$1:/tmp/
				cd $tmp
			fi
			elif [ "$2" = "--recebe" ] || [ "$2" = "recebe" ] || [ "$2" = "r" ]; then
				sshpass -p $pass scp -oStrictHostKeyChecking=no $3 $user@$1:$3 $tmp 2> $logerr
				cd $tmp
				if [ $(cat $logerr | grep "Permission denied" | wc -l) -eq 1 ]; then
					sshpass -p $pass scp -oStrictHostKeyChecking=no $3 trbw2k'\'$user@$1:$3 $tmp
					cd $tmp
				fi
		else
			# SSH
			sshpass -p $pass ssh -Y -oStrictHostKeyChecking=no $user@$1 -X 2> $logerr
			if [ $(cat $logerr | grep "Permission denied" | wc -l) -eq 1 ]; then
				sshpass -p $pass ssh -q -Y -oStrictHostKeyChecking=no trbw2k'\'$user@$1 -X
			else
				cat $logerr
			fi
		fi
		#rm -f $log $logerr
	fi
fi
