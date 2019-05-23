#!/bin/bash

if [ "$1" = "M" ] || [ "$1" = "m" ]; then
	loteria="M"
	elif [ "$1" = "L" ] || [ "$1" = "l" ]; then
		loteria="L"
		else
		read -p "Qual surpresinha deseja gerar [(M) Mega Sena|(L) Lotofacil] ? " loteria
		if [ -z $loteria ]; then
			loteria="L"
		fi
fi

loteria=$(echo $loteria | tr 'a-z' 'A-Z'); #echo $loteria
read -p "Quantos jogos desejas marcar [1] ? " qq
if [ -z $qq ]; then
	qq=1
fi
qq=$(echo $qq | tr -cd '[[:digit:]]')

if [ $loteria = "M" ]; then
	read -p "Quantos numeros voce deseja marcar na Mega Sena [6] ? " qtde
	qtde=$(echo $qtde | tr -cd '[[:digit:]]')
	if [ -z $qtde ]; then
		qtde=6
	fi
	i=1
	while [ $i -le $qq ]; do
		shuf -i 1-60 -n $qtde | sort -g | sed ':a;$!N;s/\n/-/g;ta'
		i=$(($i+1))
	done
	elif [ $loteria = "L" ]; then
	read -p "Quantos numeros voce deseja marcar na Lotofacil [15] ? " qtde
	qtde=$(echo $qtde | tr -cd '[[:digit:]]')
	if [ -z $qtde ]; then
		qtde=15
	fi
		i2=1
		while [ $i2 -le $qq ]; do
			#for i in $(rand -N 15 -M 25 -u); do echo $(($i+1)); done | sort -n | awk '{a=$0; printf "%s ",a,$0}'; echo
			shuf -i 1-25 -n $qtde | sort -g | sed ':a;$!N;s/\n/-/g;ta'
			i2=$(($i2+1))
		done
		else echo "Opcao invalida. Escolha a opcao correta!"
		exit 1
fi
