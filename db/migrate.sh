
set -x
LIQUIBASE_PROPERTIES=liquibase.properties

LOGVERSION=$1
if [ -z $LOGVERSION ]; then echo "Invalid argument $LOGVERSION"; fi

OPERATION=$2
if [ -z $OPERATION || $OPERATION != "-m" || $OPERATION != "-r"]; then 
    echo "Invalid argument $OPERATION"
    exit 1
else
    OPERATION=$2
fi

DRYRUN=""
if [ -z $3]; then DRYRUN="-n"; else DRYRUN=$3; fi

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
    if [ $OPERATION = "-r" ] ; then
        CHANGE_FILES=$(
        for f in changelogs/*
        do
            echo $f
        done | sort -r )
    else 
        CHANGE_FILES=$(
        for f in changelogs/*
        do
            echo $f
        done | sort )
    fi

    for cf in $CHANGE_FILES
    do
        SCHEMA=`basename $cf .sql | cut -d'-' -f2`
        LOGVERSION=`basename $cf .sql | cut -d'-' -f4`
        if [ $DRYRUN = "-d" ] ; then 
            echo $SCHEMA-$LOGVERSION
            if [ $OPERATION = "-r"] ; then 
                echo "DRYRUN: Rolling back tag:" $SCHEMA-$LOGVERSION
                liquibase $COMMON_ARGS --changeLogFile=$cf rollbackSQL $SCHEMA-$LOGVERSION;
            else
                echo "DRYRUN: Migrating changelog:" $cf
                liquibase $COMMON_ARGS --changeLogFile=$cf updateSQL;
            fi
        elif [ $DRYRUN = "-n" ] ; then
             if [ $OPERATION = "-r" ] ; then
                echo "Rolling back tag:" $SCHEMA-$LOGVERSION
                liquibase $COMMON_ARGS --changeLogFile=$cf rollback $SCHEMA-$LOGVERSION;
            else
                echo "Migrating changelog:" $cf
                TAGEXISTS=`liquibase --changeLogFile=$cf tagExists --tag $SCHEMA-$LOGVERSION 2>&1 1>/dev/tty`
                if [[ "$TAGEXISTS" == *"does NOT exist"* ]]; then
                    liquibase tag $SCHEMA-$LOGVERSION
                elif [[ "$TAGEXISTS" == *"already exists"* ]]; then
                    echo "$SCHEMA-$LOGVERSION tag already exists"
                fi
                liquibase $COMMON_ARGS --changeLogFile=$cf migrate;
            fi
        else
            echo "Invalid argument $DRYRUN"
            exit 1
        fi
    done
else
    FILES=(changelogs/*)
    SCHEMA=`basename ${FILES[0]} .sql | cut -d'-' -f2`
    if [ $DRYRUN = "-d" ]; then
        if [ $OPERATION = "-r" ] ; then
            liquibase $COMMON_ARGS --changeLogFile=changelogs/sp-$SCHEMA-changelog-$LOGVERSION.sql rollbackSQL $SCHEMA-$LOGVERSION
        elif [ $OPERATION = "-m" ] ; then
            liquibase $COMMON_ARGS --changeLogFile=changelogs/sp-$SCHEMA-changelog-$LOGVERSION.sql updateSQL
        fi
    elif [ $DRYRUN = "-n" ] ; then
        if [ $OPERATION = "-r" ] ; then
            liquibase $COMMON_ARGS --changeLogFile=changelogs/sp-$SCHEMA-changelog-$LOGVERSION.sql rollback $SCHEMA-$LOGVERSION
        elif [ $OPERATION = "-m" ] ; then
            TAGEXISTS=`liquibase --changeLogFile=$cf tagExists --tag $SCHEMA-$LOGVERSION 2>&1 1>/dev/tty`
            if [[ "$TAGEXISTS" == *"does NOT exist"* ]]; then
                liquibase tag $SCHEMA-$LOGVERSION
            elif [[ "$TAGEXISTS" == *"already exists"* ]]; then
                echo "$SCHEMA-$LOGVERSION tag already exists"
            fi
            liquibase $COMMON_ARGS --changeLogFile=changelogs/sp-$SCHEMA-changelog-$LOGVERSION.sql migrate
        fi
    else
        echo "Invalid dryrun argument $DRYRUN"
        exit 1
    fi
fi



