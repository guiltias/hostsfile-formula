# populate /etc/hosts with names and IP entries from your salt cluster
# the minion id has to be the fqdn for this to work

{%- set fqdn = grains['id'] %}
# example configuration for /etc/salt/minion:
#
# mine_functions:
#  network.ip_addrs:
#    - eth1
#  mine_interval: 2

{%- set minealias = salt['pillar.get']('hostsfile:alias', 'network.ip_addrs') %}
{%- set minions = salt['pillar.get']('hostsfile:minions', '*') %}
{%- set hosts = {} %}
{%- set pillar_hosts = salt['pillar.get']('hostsfile:hosts', {}) %}
{%- set mine_hosts = salt['mine.get'](minions, minealias) %}
{%- if mine_hosts is defined %}
{%-   do hosts.update(mine_hosts) %}
{%- endif %}
{%- do hosts.update(pillar_hosts) %}



/etc/hosts:
  file.managed:
    - mode: 644
    - contents: |
        127.0.0.1 localhost
        127.0.1.1 {{ grains['id'] }}
        ::1 localhost ip6-localhost ip6-loopback
        fe00::0 ip6-localnet
        ff00::0 ip6-mcastprefix
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters
        ff02::3 ip6-allhosts 
        {%- for name, addrlist in hosts.items() %}
        {%- if addrlist is string %}
        {{ addrlist }} {{ name }}
        {%- else %}
        {{ addrlist|first }} {{ name }}
        {%- endif %}
        {%- endfor %}
