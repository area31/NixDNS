# About
Serviço de DNS dinâmico gratuito que você precisa.

Domínio: noip.nixdns.com.br

Hostname nunca expira: incluso

Suporte técnico: Via web

Livre de propagandas: incluso

100% Uptime garantido: incluso

Preço: grátis para pessoa física ou Hackerspaces

Solicite agora mesmo --> http://www.nixdns.com.br

# Install
1- Create directory:

<code>mkdir -p /opt/hackstore/</code>

2- Clone repo:

<code>git clone https://github.com/area31/NixDNS.git ; mv NixDNS /opt/hackstore/nixdns</code>

3- Config your keys:

<code>vi /opt/hackstore/nixdns/nixdns.conf</code>


4- Include daemon in /etc/crontab:

<code>*/2 * * * *     root    /opt/hackstore/nixdns/nixdns-update &> /dev/null</code>

# More infos:

For more infos in Portuguese Brazilian language: http://www.nixdns.com.br
