# libelula-2 (aka Libelula PDP)
Libelula 2 is a public project for creating high performance Minecraft Servers.

Minimum Server requirement for 4 local instances:
* 6 CPU (12 thread)
* 32 GB RAM (6 GB per instance)
* 2x256 GB SSD (Use one SSD for the system and the other one for Minecraft /opt/)

In addition to the scripts and configurations that are is in this repository, it is highly recommended to follow the following OS configurations:

1. Download and use the lates Spigot Buildtool from the URL:
  https://www.spigotmc.org/wiki/buildtools/#latest
2. Mount a 4G RAM disk for the /tmp/ directory. fstab line:
  tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=4G 0 0
3. Create a minecraft user for languishing the instances (do NOT use root)

Regarding security, it is highly recommended to install iptables-persitent and ipset-persintent packages.

/etc/iptables/rules.v4 content:
```
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [28:6201]
:LOG-DROP - [0:0]
:LOG-DROP-IPBLOCKED - [0:0]
:LOG-DROP-LIMIT - [0:0]
-A INPUT -m set --match-set whitelist src -j ACCEPT
-A INPUT -m set --match-set blacklist src -j LOG-DROP
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i eno1 -p tcp -m tcp --dport 80 -m state --state NEW -m recent --set --name DEFAULT --mask 255.255.255.255 --rsource
-A INPUT -i eno1 -p tcp -m multiport --dports 80,25565 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 --name DEFAULT --mask 255.255.255.255 --rsource -j LOG-DROP-LIMIT
-A INPUT -m recent --rcheck --seconds 86400 --name portscan --mask 255.255.255.255 --rsource -j LOG-DROP
-A INPUT -m recent --remove --name portscan --mask 255.255.255.255 --rsource
-A INPUT -i eno1 -p tcp -m multiport --dports 20,21,22,23,25,53,111,137,139,631,8080,8081 -m recent --set --name portscan --mask 255.255.255.255 --rsource -j LOG-DROP-IPBLOCKED
-A INPUT -i eno1 -p tcp -m multiport --dports 80,25565,22933 -j ACCEPT
-A INPUT -i eno1 -j DROP
-A LOG-DROP -j LOG --log-prefix "FIREWALL-DROP "
-A LOG-DROP -j DROP
-A LOG-DROP-IPBLOCKED -j LOG --log-prefix "FIREWALL-DROP-IPBLOCKED "
-A LOG-DROP-IPBLOCKED -j DROP
-A LOG-DROP-LIMIT -j LOG --log-prefix "FIREWALL-DROP-LIMIT "
-A LOG-DROP-LIMIT -j LOG-DROP
COMMIT
```
File /etc/iptables/ipsets Content:
```
create whitelist hash:ip family inet hashsize 1024 maxelem 65536
create blacklist hash:ip family inet hashsize 1024 maxelem 65536
```

Recommended OS: Debian 10 (Buster)
Needed extra packages: libasound2 libasound2-data git sudo screen (+ The latest Oracle Java SDK)
