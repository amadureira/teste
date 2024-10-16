#!/bin/bash
SOURCE_FILE=${1:-/tmp/suporte/novosusuarios}
if [ ! -f ${SOURCE_FILE} ]
then
 echo "arquivo ${SOURCE_FILE} não existe"
 exit 1
elif [ $(id -u) -ne 0 ]
then
 	echo "Execute o script $0 como root"
	exit 1
fi
for user in $(cut -d: -f1 ${SOURCE_FILE} )
do     
	SRE_USER="sre_$user"
	COMMENT=$( grep "^$user" ${SOURCE_FILE} | cut -d:  -f2 )
	CHECK=$( grep -c "^$SRE_USER" /etc/passwd)
	test  ${CHECK} -eq 1 && echo "Usuario [${SRE_USER}] existe"  && continue
	echo "Criando [$SRE_USER]"
	useradd  -m ${SRE_USER}  -G sudo --comment "${COMMENT}" -s /bin/bash
	echo -e "${SRE_USER}\n${SRE_USER}" | passwd ${SRE_USER}
done
