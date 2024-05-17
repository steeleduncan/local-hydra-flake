State=$(pwd)/state
Db=$State/db
Lockfiles=$State/lockfiles
Conf=$Db/postgresql.conf
export HYDRA_DATA=$State/hydra

rm -rf $State

export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
mkdir -p $Db $Lockfiles $HYDRA_DATA
initdb -D $Db

echo "appending config"
echo "unix_socket_directories = '$Lockfiles'" >> $Conf

# todo grab pid to quit later
postgres -D $Db&
PostgresPid=$!
echo "Postgres started with pid: $PostgresPid"

# todo wait and supply pwd
# https://github.com/NixOS/hydra/blob/master/doc/manual/src/installation.md

createuser --host=localhost -S -D -R -P hydra
createdb --host=localhost -O hydra hydra

export HYDRA_DBI="dbi:Pg:dbname=hydra;host=localhost;user=hydra;"
hydra-init

# todo grab pid to quit later
hydra-server&
HydraPid=$!
echo "Hydra started with pid: $HydraPid"

hydra-evaluator&
EvaluatorPid=$!
echo "Evaluator started with pid: $EvaluatorPid"

hydra-queue-runner&
RunnerPid=$!
echo "Runner started with pid: $RunnerPid"

function cleanup() {
    kill $PostgresPid
    kill $HydraPid
    kill $RunnerPid
    kill $EvaluatorPid
}
trap cleanup INT

sleep 10
cleanup
