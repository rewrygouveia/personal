#!/bin/bash

export USER="rewry.menezes"
export GROUP="wheel"

# Colors Shell
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
end="\033[0m"
bold=$(tput bold)
normal=$(tput sgr0)
master_password="<senha-master>"

pathdb="/home/rewry.menezes/bin/Linux/PuTTy"
db="$pathdb/database.csv"
script="$pathdb/connect.sh"
t="/tmp/connect-$RANDOM"

if [ ! -f $db ]; then
	echo -e "$red""Arquivo de banco de dados $db nao encontrado.""$end"
	exit 1
fi

f_aviso(){
echo "Desculpe-nos o transtorno. Estamos contruindo esta rotina ;)"
exit 1
}

f_warning(){
warm=$(cat $db | grep " " | wc -l)
if [ $warm -gt 0 ]; then
	echo -e "$yellow""*** ATENÇÃO: Ha inconsistencias no arquivo de banco de dados! ***""$end"
fi
}

f_validaPesquisa(){
pesquisa=$(cat $db | grep ,$p, | wc -l)
if [ $pesquisa -gt 1 ]; then
	echo -e "$yellow""Ha $pesquisa resultados DUPLICADOS em sua pesquisa. Abra o arquivo de dados e refine sua pesquisa.""$end"

	echo; cat $db | grep ,$p,; echo

	exit 1
	elif [ $pesquisa -eq 0 ]; then
		echo -e "$yellow""Nada foi encontrado!""$end"
		exit 1
fi
}

f_testaPing(){
if [ $(fping -q $endereco; echo $?) -eq 1 ]; then
	echo -e "$yellow""O Host $endereco esta inacessivel ou não há regra de ICMP para este servidor!""$end"
	#exit 0
fi
}

f_testaPorta(){
if [ $(nc -z $endereco $porta; echo $?) -eq 1 ]; then
	echo -e "$red""Host $endereco ou Porta $porta indisponivel!""$end"
	exit 1
	else f_testaPing
fi
}

f_mount(){

shared=/shared
if [ ! -d $shared ]; then
	sudo mkdir $shared
fi
		
if [ -z $dominio ]; then
	dominio="$hostname"
fi

echo
read -p "Informe o path de origem [//$(echo $endereco)/c$]: " origem
#read -p "Informe o path de destino [$(echo $shared)/c]: " destino
read -p "Informe o usuario [`echo $usuario`]: " usuario_mount
read -p "Informe a senha: [`echo $senha`] " senha_mount
read -p "Informe o dominio (se houver) [$(echo $dominio)]: " dominio_mount

if [ -z $origem ]; then
	origem=c$
fi

destino(){
if [ -z $destino ]; then
	destino=$shared/c
	if [ ! -d $shared/c ]; then
		sudo mkdir -p $shared/c
	fi
	elif [ ! -d $shared/$destino ]; then
		sudo mkdir -p $shared/$destino
		destino=$shared/$destino
		else destino=$shared/$destino
fi
}
#destino

rand=`tr -dc a-z < /dev/urandom | head -c 4`
destino=$shared/$rand
sudo mkdir -p $destino

if [ -z $usuario_mount ]; then
	usuario_mount=$usuario
fi

if [ -z $senha_mount ]; then
	senha_mount=$senha
fi

if [ -z $dominio_mount ]; then
	dominio_mount=$dominio
fi

echo
echo "Path de origem:  " //$endereco/$origem
echo "Path de destino: " $destino
echo "Usuario:         " $usuario
echo "Dominio:         " $dominio
echo

testa_mount=$(df | grep $destino | wc -l)
if [ $testa_mount -ge 1 ]; then
read -p "Ha um ponto de montagem no diretorio $destino. Desejas desmontar? [s|N] " dismount
dismount=$(echo $dismount | tr 'A-Z' 'a-z')
	if [ "$dismount" = "s" ]; then

		sudo umount -l $destino
		if [ $? -gt 0 ]; then
			echo -e "$red""Houve um erro na desmontagem do diretorio $destino!""$end"
			exit 1
		fi

		read -p "O diretorio foi desmontado com sucesso. Deseja continuar? [S|n] " continua
		continua=$(echo $continua | tr 'A-Z' 'a-z')
		if [ "$continua" = "n" ]; then
			echo -e "$yellow""Nada foi feito!""$end"; exit 1
		fi

		else echo -e "$yellow""Nada foi feito!""$end"; exit 1
	fi
fi

#sudo mount.cifs //$endereco/$origem $destino -o user=$usuario,pass=$senha,dom=$dominio,uid=$USER,gid=$GROUP,iocharset=utf8,sec=ntlm
sudo mount.cifs //$endereco/$origem $destino -o user=$usuario,pass=$senha,dom=$dominio,uid=$USER,gid=$GROUP

if [ $? -gt 0 ]; then
	echo -e "$red""Houve um erro na montagem do $hostname no path $destino.""$end"
	#sudo rm -rf $destino
	exit 1
fi
}

f_vnc(){
vnc=/opt/vnc-viewer/VNC-Viewer-5.0.5-Linux-x86
$vnc $endereco:$porta &
}

f_select(){
cat $db | grep ,$p, | tr ',' '\n' > $t
senha=$(cat $t | sed '1!d')
sistema_operacional=$(cat $t | sed '2!d')
hostname=$(cat $t | sed '3!d')
descricao=$(cat $t | sed 's/"//g' | sed '4!d')
ambiente=$(cat $t | sed '5!d')
endereco=$(cat $t | sed '6!d')
endereco2=$(cat $t | sed '7!d')
endereco3=$(cat $t | sed '8!d')
endereco4=$(cat $t | sed '9!d')
endereco5=$(cat $t | sed '10!d')
usuario=$(cat $t | sed '11!d')
dominio=$(cat $t | sed '12!d')
id=$(cat $t | sed '13!d')
porta=$(cat $t | sed '14!d')
protocolo=$(cat $t | sed '15!d')
aplicacao=$(cat $t | sed '16!d')
tipo=$(cat $t | sed '17!d')
local=$(cat $t | sed '18!d')
site=$(cat $t | sed '19!d')
status=$(cat $t | sed '20!d')
monitorado=$(cat $t | sed '21!d')
empresa=$(cat $t | sed '22!d')
nota=$(cat $t | sed '23!d')

rm -f $t

echo
echo "ID                   :" $id
echo "Sistema Operacional  :" $sistema_operacional
echo "Tags                 :" $descricao
echo "Hostname             :" $hostname
echo "Ambiente             :" $ambiente
echo "Endereco IP/DNS      :" $endereco $endereco2 $endereco3 $endereco4 $endereco5
echo "Usuario              :" $usuario
echo "Senha                :" $senha
echo "Dominio              :" $dominio
echo "Porta [Protocolo]    :" $porta "["$protocolo"]"
echo "Local [Site]         :" $local "["$site"]"
echo "Aplicação [Tipo]     :" $aplicacao "["$tipo"]"
#echo "Status              :" $status
echo "Nota                 :" $nota
echo
}

f_conecta(){
if [ ! -f /usr/bin/xtitle ]; then
	sudo apt-get install -y xtitle
	echo -e "$green""xtitle instalado com sucesso!""$end"
	exit 1
fi

f_select
if [ "$protocolo" = "SSH" ]; then
	# Automatically change the gnome-terminal "title" for the window
	PS1="\[\e]0;"$endereco"\a\]\u@\h:\w\$"
	xtitle -t $id/$endereco/$hostname

	f_testaPorta
	if [ "$e" = "envia" ]; then

		f_envia(){
		for i in $arquivo; do
			if [ ! -f $i ]; then
				echo -e "$yellow""Arquivo $i nao existe!""$end"
			fi
		done
		}
		#f_envia

		scp -q -P $porta $arquivo $usuario@$endereco:/tmp/

		if [ "$?" = 0 ]; then
			echo -e "$green""Arquivo $arquivo enviado com sucesso!""$end"
			else echo -e "$red""Houve uma falha no envio do arquivo!""$end"
		fi

		elif [ "$e" = "recebe" ]; then

			ssh -q $usuario@$endereco -p $porta sudo chmod 775 $arquivo
			scp -r -q -P $porta $usuario@$endereco:$arquivo /tmp/

			if [ "$?" = 0 ]; then
				echo -e "$green""Arquivo recebido com sucesso!""$end"
				else echo -e "$red""Houve uma falha no recebimento do arquivo!""$end"
			fi

		else

		#ssh-keygen -f "$HOME/.ssh/known_hosts" -R $endereco >/dev/null
		ssh -Y -q $usuario@$endereco -p $porta -X

		f_error(){
		if [ "$?" != 0 ]; then
			echo -e "$yellow""ATENÇÃO: Houve um ERRO de conectividade SSH!""$end"
		fi
		}
		#f_error

	fi
	xtitle `pwd`

	elif [ "$protocolo" = "NFS" ]; then
		if [ -z $senha ]; then
			senha=$master_password
			else senha=$senha
		fi
		f_testaPing
		f_mount
		#exit 0

	elif [ "$protocolo" = "VNC" ]; then
		if [ -z $senha ]; then
			senha=$master_password
			else senha=$senha
		fi

		f_testaPing

		if [ `nc -z $endereco $porta; echo $?` -eq 0 ]; then
			vnc=/opt/vnc-viewer/VNC-Viewer-5.0.5-Linux-x86
			$vnc $endereco:$porta &
			else echo -e "$red""Porta inacessivel!""$end"
		fi

	elif [ "$protocolo" = "RDP" ]; then

		if [ "$usuario" = "rewry.menezes" ]; then
			senha=$master_password
			else senha=$senha
		fi
	
		f_testaPorta
		read -p "Desejas realizar uma conexao remota [R] ou montar um disco [M]? [R|m] " c
		c=$(echo $c | tr 'A-Z' 'a-z')
		if [ -z $c ] || [ $c = "r" ]; then
	
			read -p "Tela cheia [F], tela inteira [I] ou meia tela [M]? [f|I|m] " t
			t=$(echo $t | tr 'A-Z' 'a-z')

			if [ -z $t ] || [ "$t" = "i" ] ; then

				#desktop="-g 1366x692" # Gonme Classic
				#desktop="-g 1336x728" # Unity Ubuntu 14.04 Trusty
				#desktop="-g 1342x738" # Unity Ubuntu 14.04 com escala de 0,625
				#desktop="-g 1368x728"  # Unity Ubuntu 14.04 com docky
				desktop="-g 1331x722" # Unity
				#desktop="-g 1378x712" # Elementary
				#desktop="-g 1366x768" # Unity Fullscreen
				#desktop="-g 1366x692" # Gnome
				#desktop="-g 1366x674" # Unity3, Ubuntu 17.10
				#desktop="-g 1366x682"

				elif [ "$t" = "m" ]; then
					desktop="-g 1024x680"	

				elif [ "$t" = "f" ]; then
					desktop="-f"

				else echo -e "$yellow""Informe a opção correta!""$end"; exit 1
			fi

			if [ -z $dominio ]; then
				dominio="$hostname"
			fi

			if [ ! -z "$dominio" ]; then

				# Usage: rdesktop [options] server[:port]
				cores="-a 16"
				share="-r disk:HOME=$HOME -r disk:PDF=$HOME/ProgramFiles/Evince-2.32.0.145 -r disk:CCLEAN=$HOME/ProgramFiles/CCleaner -r disk:EVINCE=$HOME/ProgramFiles/Evince-2.32.0.145 -r disk:INSTALL=$HOME/Programas/ -r disk:TMP=/tmp"
				som="-r sound:local"
				clipboard="-r clipboard:PRIMARYCLIPBOARD"
				outras_opcoes="-P -z -x -b -K"
				usuario="-u $usuario"
				senha="-p $senha"
				dominio="-d $dominio"
				endereco="$endereco:$porta"
				janela="-T $endereco/$hostname"

				rdesktop $cores $desktop $share $som $clipboard $outras_opcoes $usuario $senha $dominio $endereco $janela -0 & >/dev/null
				else
				rdesktop $cores $desktop $share $som $clipboard $outras_opcoes $usuario $senha $endereco $janela -0 & >/dev/null
			fi

			if [ $? -gt 0 ]; then
				echo -e "$red""Houve um erro na conexão remota [Rdesktop].""$end"
				exit 1
			fi

			elif [ "$c" = "m" ]; then
				f_mount
				cd $destino

			else echo -e "$yellow""Informe a opção correta.""$end"; exit 1

	fi
	#xtitle `pwd`

	#else echo -e "$yellow""Sistema Operacional não encontrado!""$end"
	else echo -e "$red""EXCEÇÃO DO LAÇO""$end"
fi
}


### MENU ###
if [ ! -z $1 ]; then
	p=$1
	e=$2
	# How to remove nth element from command arguments in bash
	arquivo="${@:3:$#}"
	else
		echo
		read -p "   Informe o "$bold"'ID'"$normal" da pesquisa ou,
   "$bold"'P'"$normal" para pesquisar ou,
   "$bold"'O'"$normal" para abri o arquivo de dados no LibreOffice,
   "$bold"'B'"$normal" para realizar um backup do arquivo de dados ou,
   "$bold"'D'"$normal" para abri o arquivo de dados no Bloco de Notas ou,
   "$bold"'E|S'"$normal" para abrir o script (no gedit) ou,
   "$bold"'M'"$normal" para montar o disco ou,
   "$bold"'A'"$normal" para alterar para o IP da VALECARD ou,
   "$bold"'ENVIA|RECEBE'"$normal" para enviar|receber um arquivo: " p #ou "$bold"A"$normal" para executar script de auditoria
echo
fi

p=$(echo $p | tr 'A-Z' 'a-z')
f_warning

if [ -z $p ]; then
	echo -e "$yellow""Nenhuma pesquisa foi informada.""$end"
	echo; 
	exit 0

	elif [ "$p" = "p" ]; then
		if [ -z $2 ]; then
			read -p "Informe o criterio da pesquisa: " pp
			else pp=$2
		fi
		pp=$(echo $pp | tr 'A-Z' 'a-z')
			if [ -z $pp ]; then
				echo -e "$yellow""Nenhum criterio de pesquisa foi informado!""$end"
				echo
				exit 1
			fi

		awk -F',' '{print $3, $4, $5, $11, $6, $7, $8, $9, $13"/"$14, $15, $16, $17, $18"/"$19, $22}' $db | tr 'A-Z' 'a-z' | egrep 'tags|'$pp'' | column -ntex

	elif [ "$p" = "o" ]; then
		calc=/opt/libreoffice5.2/program/soffice.bin
		if [ ! -f $calc ]; then
			echo -e "$red""LibreOffice não está instalado ou não foi encontrado!""$end"
			exit 1
			else $calc $db &
		fi

	elif [ "$p" = "d" ]; then
		notepad=/usr/bin/gedit
		if [ ! -f $notepad ]; then
			echo -e "$red""Gedit não está instalado ou não foi encontrado!""$end"
			exit 1
			else $notepad $db &
		fi

	elif [ "$p" = "e" ] || [ "$p" = "s" ]; then
		if [ ! -f $HOME/bin/Linux/PuTTy/connect.sh ]; then
			echo -e "$red""Arquivo não encontrado!""$end"
			exit 1
			else
				if [ -f /usr/bin/gedit ]; then
					gedit $HOME/bin/Linux/PuTTy/connect.sh &
					else echo -e "$red""Editor de texto 'gedit' nao encontrado""$end"; exit 1
				fi
		fi

	elif [ "$p" = "envia" ]; then
		echo -e "$yellow""Use: connect <ID> envia <arquivo>""$end"
		exit 1

	elif [ "$p" = "a" ]; then
		sudo ifconfig eth0 192.168.14.9 netmask 255.255.240.0; sudo route add default gw 192.168.10.1
		exit 1

	elif [ "$p" = "m" ]; then
		read -p "Informe o endereço IP de origem: " endereco
		f_testaPing
		f_mount

	elif [ "$p" = "m" ]; then
		read -p "Informe o endereço IP de origem: " endereco
		f_testaPing
		f_mount

	elif [ "$p" = "b" ]; then
		data=`date +%Y%m%d-%H%M%S`

		cp $script $script-$data && cp $db $db-$data

		if [ $? -ne 0 ]; then
			echo -e "$red""Houve um ERRO na copia do banco e script de dados.""$end"
			else echo -e "$green""Backup do banco e script realizado com sucesso!""$end"
		fi

	elif [ "$p" = "a" ] || [ "$p" = "s" ]; then
		if [ -z $2 ]; then
			read -p "Informe o ID: " p
			else p=$2
		fi		

		f_select
		f_testaPorta

		if [ "$sistema_operacional" != "Linux" ]; then
			echo "Auditoria NAO se APLICA!"
			exit 1
		fi

		audit=/tmp/auditoria
		if [ ! -f $audit ]; then
			touch $audit
		fi
		read -p "Informe o path do script: [`cat $audit`] " path
		if [ -z $path ] && [ -z `cat $audit` ]; then
			echo "Arquivo nao encontrado! (1)"
			exit 1

			elif [ ! -f `cat $audit` ]; then
				echo "Arquivo nao encontrado! (2)"
				exit 1

			elif [ -z $path ] && [ ! -z `cat $audit` ]; then
				echo

				else echo $path > $audit
		fi
	
		read -p "Desejas continuar? [S|n] " continua
		continua=$(echo $continua | tr 'a-z' 'A-Z')
		if [ -z $continua ] || [ $continua = "S" ]; then
			ssh -q $usuario@$endereco bash < `cat $audit`
			scp -q $usuario@$endereco:~/KPMG-Audit_UNIX*.txt /tmp/
			if [ $? -ne 0 ]; then
				echo "Houve um ERRO na execucao do script!"
			fi
			echo
			else
				echo "Nada foi feito!"
				exit 1
		fi

	else
		#f_warning
		f_validaPesquisa
		f_conecta
fi
