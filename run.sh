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

# todo wait and supply pwd
# https://github.com/NixOS/hydra/blob/master/doc/manual/src/installation.md

createuser --host=localhost -S -D -R -P hydra
createdb --host=localhost -O hydra hydra

export HYDRA_DBI="dbi:Pg:dbname=hydra;host=localhost;user=hydra;"
hydra-init

# todo grab pid to quit later
hydra-server&
hydra-evaluator&
hydra-queue-runner
