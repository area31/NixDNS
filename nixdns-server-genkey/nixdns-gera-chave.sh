#!/bin/bash

DATA=$(date +%d-%m-%Y)

HOST="noip.nixdns.com.br"
FILE="named.conf"
CONFDIR="/etc/bind"
KEYDIR="/opt/nixdns/chaves"
BKPDIR="${CONFDIR}/backup"
NAMEDCONF="${CONFDIR}/${FILE}"
FILEZONE="/var/bind/nixdns/noip.nixdns.com.br.zone"
JOURNAL="${FILEZONE}.jnl"

# Solicita dados para geração do dnshackstore
echo -e "\n"
read -p "Digite o nome do cliente: " CLIENTE

CHECK_KEY=$( grep ${CLIENTE}.${HOST} ${NAMEDCONF} | grep -i grant | wc -l )
if [ "${CHECK_KEY}" -ne 0 ]; then
        echo -e "\n\033[1;31mERRO: JÁ EXISTE ESTE DNSHACKSTORE.\033[m\017\n"
        ERROR=1;
	exit 1
fi
echo -e "\n\033[1;33mCriando host:\033[m\017 \033[00;32m${CLIENTE}.${HOST}"
echo -e "\033[1;33mContinuar?\033[m\017 \033[1;31mSe não deseja continuar pressione (CRTL+C)\033[m\017"
read


# Gera a chave
mkdir -p ${KEYDIR}
cd ${KEYDIR}
dnssec-keygen -a RSAMD5 -b 1024 -n HOST -v 0 -T KEY -C -r /dev/urandom ${CLIENTE}.${HOST}

# Cria backup da configuração
mkdir -p ${BKPDIR}
cp ${NAMEDCONF} ${BKPDIR}/${FILE}.bkp-${DATA}

# Habilita para fazer upload da zona
cat ${NAMEDCONF} | sed s/"\/\/INSERT KEY HERE"/"\/\/INSERT KEY HERE\ngrant ${CLIENTE}.${HOST}. name ${CLIENTE}.${HOST} A;"/g > ${NAMEDCONF}.tmp

/etc/init.d/named stop 1> /dev/null;
mv ${NAMEDCONF}.tmp ${NAMEDCONF}

cat K${CLIENTE}*.key >> ${FILEZONE}

rm ${JOURNAL}

# Corrige permissões de arquivos
chown named.named -R ${BKPDIR}
chown named.named -R ${CONFDIR}
chown named.named -R ${KEYDIR}

/etc/init.d/named start 1> /dev/null;

echo -e "\n\nVocê deve enviar os arquivos de chave \033[00;32m${KEYDIR}/K${CLIENTE}.${HOST}.*\033[m\017 para o cliente, para poder fazer a atualização do DNS."


