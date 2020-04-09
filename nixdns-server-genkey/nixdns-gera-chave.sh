#!/bin/bash

DATA=$(date +%d-%m-%Y_%H%M%S)

HOST="noip.nixdns.com.br"
FILE="named.conf"
CONFDIR="/etc/bind"
KEYDIR="/var/bind/chaves"
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
rm -f K${CLIENTE}.${HOST}*.key K${CLIENTE}.${HOST}*.private
dnssec-keygen -r /dev/urandom -a HMAC-MD5 -b 512 -n HOST ${CLIENTE}.${HOST}

# Cria backup da configuração
mkdir -p ${BKPDIR}
cp ${NAMEDCONF} ${BKPDIR}/${FILE}.bkp-${DATA}

# Habilita para fazer upload da zona
cat ${NAMEDCONF} | sed s,"\/\/INSERT KEY HERE","\/\/INSERT KEY HERE\ngrant ${CLIENTE}.${HOST}. name ${CLIENTE}.${HOST} A;",g > ${NAMEDCONF}.tmp2

KEYSECRET="$(cat ${KEYDIR}/K${CLIENTE}.${HOST}*.key|awk '{print $7, $8}')"
cat ${NAMEDCONF}.tmp2 | sed s,"\/\/INSERT KEYSECRET HERE","\/\/INSERT KEYSECRET HERE\nkey \"${CLIENTE}.${HOST}\" { algorithm hmac-md5; secret \"${KEYSECRET}\"; };",g > ${NAMEDCONF}.tmp


# Stopping named
rndc freeze noip.nixdns.com.br
rndc thaw noip.nixdns.com.br
echo "parando BIND..."
sleep 2


/etc/init.d/named stop 1> /dev/null;
mv ${NAMEDCONF}.tmp ${NAMEDCONF}

cat K${CLIENTE}*.key >> ${FILEZONE}

rm ${JOURNAL}

# Corrige permissões de arquivos
chown named.named -R ${BKPDIR}
chown named.named -R ${CONFDIR}
chown named.named -R ${KEYDIR}

echo "iniciando BIND..."

/etc/init.d/named start 1> /dev/null;

echo -e "\n\nVocê deve enviar os arquivos de chave \033[00;32m${KEYDIR}/K${CLIENTE}.${HOST}.*\033[m\017 para o cliente, para poder fazer a atualização do DNS."
