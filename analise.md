# Análise inicial:

Como o comando netstat -tlnp vi que o serviço do mysql, apache estava down. o serviço do  rabbitmq estava UP, escutando na porta 5672 e 25672


# Problemas no serviço mysql

O parâmentro includedir estava configurado de forma incorreta, faltava o simbolo ! no inicio da linha conforme Doc: https://dev.mysql.com/doc/refman/8.4/en/option-files.html

Este problema foi descoberto analisando os logs do serviço com o comando ```journalctl -u mysql```
Também habilitei o serviço do mysql para iniciar no start da maquina.


# Problemas com apache

Analisando os logs do com o comando ```journalctl -u apache2``` , encontrei o erro abaixo:

```
Oct 14 18:14:25 lab-mgc-1001 apachectl[665]: AH00526: Syntax error on line 19 of /etc/apache2/sites-enabled/000-default.conf:
Oct 14 18:14:25 lab-mgc-1001 apachectl[665]: Invalid command 'InvalidDirective', perhaps misspelled or defined by a module not included in the server confi>
```

Analisando o arquivo informado no log encontrei e comentei a config abaixo:

```
InvalidDirective On
```

Para garantir  que o serviço subiria no boot da máquina, também habilitei o apache2 como comando 
```
systemctl status enable apache2
```

# Problemas no rabbitmq-server

O Serviço do rabbitmq estava executando, porém não consegui executar o comando rabbitmqctl status, devido ao alto consumo de CPU e memória, indicados no item *Problemas de scripts* . Após resolver este problema, dedici reiniciar o serviço do rabbitmq para ter certeza  de que estava funcionando. Após o restart o mesmo não subiu. Olhando os logs do arquivo */var/log/rabbitmq/rabbit\@lab-mgc-1001.log* identifiquei que o serviço estava tentando subir na porta 80. Para resolver este problema , comentei a linha abaixo no arquivo */etc/rabbitmq/rabbitmq-env.conf* . Após esta ação, o rabbitmq subiu e o comando *rabbitmqctl status* retornou o estado esperado.


# Problemas de scripts. 

A máquina apresentou um comportamento estranho, analisando o consumo de recursos da máquina com o comando ```top``` encontrei 2 scripts disparados pelo cron do root. o ```/usr/local/bin/cpu_hog.sh``` e o ```/usr/local/bin/memory_leak.sh```. Matei estes scripts com o comando kill e comentei as linhas da cron. 


# Observações:

Tentei conectar no servidor web pelo meu browser, mas não consegui. Pelo que pude analisar não existia regras de IPTables bloqueando o acesso. Então entendo que temos um bloqueio da porta 80 para o mundo. 

git@github.com:amadureira/scripts.git