#! /bin/bash
set -e

# Server Configuration Variables
SERVER_BIN="/opt/minecraft/libelula-2/spigot/bin/spigot*.jar"
SERVER_RES="./server.resouces"
MINECRAFT_USER="minecraft"

# Server Performance Variables
XMS="8G"		# GB RAM assigned
NICE_VALUE="-20"	# Highest prio

# Autoconfigurable server Variables
XMX=$XMS
INSTANCE="${PWD%"${PWD##*[!/]}"}";INSTANCE="${INSTANCE##*/}"
INSTANCE_FILE="/tmp/$INSTANCE.sh"

if [ -f $SERVER_RES ]
then
	echo "Resources file found, loading configuration."
	. $SERVER_RES
	echo "Current performance configuration:"
else
	echo "***********************************************************"
	echo "** Warning: NO Server resources configuration available. **"
	echo "***********************************************************"
	echo "Using default performance parameters:"
fi
echo "Instance Name:" $INSTANCE
echo "Xms:" $XMS
echo "Xmx:" $XMX

RUN_LINE="java \
       		-Xms$XMS -Xmx$XMX \
 		-XX:NewRatio=3 -XX:+UseThreadPriorities \
        	-XX:SoftRefLRUPolicyMSPerMB=2048 \
        	-XX:CMSInitiatingOccupancyFraction=90 \
        	-XX:+DisableExplicitGC -XX:+CMSParallelRemarkEnabled \
        	-XX:MaxGCPauseMillis=50 -XX:ParallelGCThreads=4 \
	        -XX:+UseAdaptiveGCBoundary -XX:-UseGCOverheadLimit -XX:+UseBiasedLocking \
        	-XX:SurvivorRatio=8 -XX:TargetSurvivorRatio=90 -XX:MaxTenuringThreshold=15 \
        	-ss4M -XX:UseSSE=4 -XX:+UseLargePages \
        	-XX:+UseCompressedOops -XX:+OptimizeStringConcat \
        	-jar $SERVER_BIN \
        	nogui"

echo '#! /bin/bash' > $INSTANCE_FILE
echo $RUN_LINE >> $INSTANCE_FILE
chmod a+x $INSTANCE_FILE

nice -n $NICE_VALUE sudo -u $MINECRAFT_USER screen -d -m -S $INSTANCE bash $INSTANCE_FILE
echo "Server launched."
