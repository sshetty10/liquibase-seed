
set -x
LIQUIBASE_PROPERTIES=liquibase.properties
SCHEMA="gym"

LOGVERSION=""
if [ -z $1 ]; then LOGVERSION="all"; else LOGVERSION=$1; fi

OPERATION=""
if [ -z $2]; then OPERATION="-m"; else OPERATION=$2; fi

function getValue {
       KEY=$1
       VALUE=`cat $LIQUIBASE_PROPERTIES | grep "$KEY" | cut -d'=' -f2`
       echo $VALUE
    }

PG_URL=$(getValue "url")
PG_USER=$(getValue "username")
PG_PASS=$(getValue "password")
PG_DRIVER=$(getValue "driver")
PG_CLASSPATH=$(getValue "classpath")

COMMON_ARGS="--driver=$PG_DRIVER\
        --url=$PG_URL \
        --username=$PG_USER \
        --password=$PG_PASS \
        --classpath=$PG_CLASSPATH"

if [ $LOGVERSION = "all" ]; then
    CHANGE_FILES=$(
    for f in changelog/*
    do
        echo $f
    done | sort )

    for cf in $CHANGE_FILES
    do
        if [$OPERATION = "-r"] ; then 
            liquibase $COMMON_ARGS --changeLogFile=$cf rollback $LOGVERSION;
        else
            liquibase $COMMON_ARGS --changeLogFile=$cf migrate;
        fi
    done
else
    if [ $OPERATION = "-r" ]; then
        liquibase $COMMON_ARGS --changeLogFile=changelogs-json/sp-$SCHEMA-changelog-$LOGVERSION.json rollback $LOGVERSION;
    else
        liquibase $COMMON_ARGS --log-level=FINE --changeLogFile=changelogs-json/sp-$SCHEMA-changelog-$LOGVERSION.json migrate;
    fi
fi



