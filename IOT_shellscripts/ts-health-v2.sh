#/bin/bash

indent=8
indspaces="        "

ts0conn=`kubectl exec phziot-timescaledb-0 -n phziot -- pg_isready -h localhost -p 5432 2> /dev/null`
ts1conn=`kubectl exec phziot-timescaledb-1 -n phziot -- pg_isready -h localhost -p 5432 2> /dev/null`
ts2conn=`kubectl exec phziot-timescaledb-2 -n phziot -- pg_isready -h localhost -p 5432 2> /dev/null`

ts0patrA=`kubectl exec phziot-timescaledb-0 -n phziot -- curl localhost:8008 2> /dev/null`
ts1patrA=`kubectl exec phziot-timescaledb-1 -n phziot -- curl localhost:8008 2> /dev/null`
ts2patrA=`kubectl exec phziot-timescaledb-2 -n phziot -- curl localhost:8008 2> /dev/null`

ts0patrRoleB=${ts0patrA#*role\": \"}
ts0patrRole=${ts0patrRoleB%%\"*}
ts0patrStateB=${ts0patrA#*state\": \"}
ts0patrState=${ts0patrStateB%%\"*}

ts1patrRoleB=${ts1patrA#*role\": \"}
ts1patrRole=${ts1patrRoleB%%\"*}
ts1patrStateB=${ts1patrA#*state\": \"}
ts1patrState=${ts1patrStateB%%\"*}

ts2patrRoleB=${ts2patrA#*role\": \"}
ts2patrRole=${ts2patrRoleB%%\"*}
ts2patrStateB=${ts2patrA#*state\": \"}
ts3patrState=${ts2patrStateB%%\"*}

echo ""
echo "** Basic Connection Information **"
echo "    Timescale-0: ${ts0conn#*-}"
echo "    Timescale-1: ${ts1conn#*-}"
echo "    Timescale-2: ${ts2conn#*-}"
echo ""
echo "** Patroni Status Information **"
echo "    Timescale-0   state: $ts0patrState   role: $ts0patrRole"
echo "    Timescale-1   state: $ts0patrState   role: $ts1patrRole"
echo "    Timescale-2   state: $ts0patrState   role: $ts2patrRole"
echo ""

ts0table=`kubectl exec phziot-timescaledb-0 -n phziot -- bash -c "PGPASSWORD=$PATRONI_SUPERUSER_PASSWORD psql -h localhost -U postgres -d merck -c '\dt' | grep table | cut -d '|' -f2"`

echo "** Table Sync Information **"
echo "    Sync Status      Node 0   Node 1   Node 2     Table Name"

for line in $ts0table; do

	ts0count=`kubectl exec phziot-timescaledb-0 -n phziot -- bash -c "PGPASSWORD=$PATRONI_SUPERUSER_PASSWORD psql -h localhost -U postgres -d merck -c 'select count(*) from $line'" 2> /dev/null | head -3 | tail -1 | sed 's/ //g' 2> /dev/null`
	ts1count=`kubectl exec phziot-timescaledb-1 -n phziot -- bash -c "PGPASSWORD=$PATRONI_SUPERUSER_PASSWORD psql -h localhost -U postgres -d merck -c 'select count(*) from $line'" 2> /dev/null | head -3 | tail -1 | sed 's/ //g' 2> /dev/null`
	ts2count=`kubectl exec phziot-timescaledb-2 -n phziot -- bash -c "PGPASSWORD=$PATRONI_SUPERUSER_PASSWORD psql -h localhost -U postgres -d merck -c 'select count(*) from $line'" 2> /dev/null | head -3 | tail -1 | sed 's/ //g' 2> /dev/null`

	if [ -z "${ts0count}" ]; then
		ts0count="error"
	fi

	if [ -z "${ts1count}" ]; then
		ts1count="error"
	fi

	if [ -z "${ts2count}" ]; then
		ts2count="error"
	fi

        tlc0="${ts0count:0:$indent}${indspaces:0:$(($indent - ${#ts0count}))}"
        tlc1="${ts1count:0:$indent}${indspaces:0:$(($indent - ${#ts1count}))}"
        tlc2="${ts2count:0:$indent}${indspaces:0:$(($indent - ${#ts2count}))}"

	sync_status="ERROR          "
	if [[ $tlc0 != $tlc1 || $tlc0 != $tlc2 ]]; then
		sync_status="OUT OF SYNC    "
	fi

        if [[ $tlc0 == $tlc1 || $tlc0 == $tlc2 ]]; then
                sync_status="PARTIAL SYNC   "
        fi

        if [[ $tlc0 == $tlc1 && $tlc0 == $tlc2 ]]; then
                sync_status="GOOD SYNC      "
        fi

	echo "    $sync_status  $tlc0 $tlc1 $tlc2   $line"
done
echo ""
echo "** End Report **"
echo ""
