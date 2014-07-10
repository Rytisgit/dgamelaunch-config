#! /bin/bash
#############################################################################
#
# WARNING!  AUTO-GENERATED FILE, DO NOT EDIT.
#
# This file (dwarf-fortress-launcher.sh) is automatically generated from /home/crawl-dev/crawl-dev/dgamelaunch-config/chroot/bin/dwarf-fortress-launcher.sh.
#
# Do NOT edit this file; edit /home/crawl-dev/crawl-dev/dgamelaunch-config/chroot/bin/dwarf-fortress-launcher.sh instead, and
# use `dgl publish` to publish your changes.
#
#############################################################################
#

user=$1
major_version=$2
#don't use / for end of path so find/replace works correctly

dfdir="/dfdir/${major_version}/df_linux"
userdir="/dfdir/${major_version}/df_$user"
dflauncher="/bin/df-launch.sh"
dwizzell="/bin/dwizzell.pl.sh"
MAXGAMES=6
inprogressdir="/dgldir/inprogress/dwarf-fortress"
userdirbak="/dfdir/${major_version}/bak_df_$user"

#check to see if dir exist
#if so, updateflag = 1, indicating we need to update, not new install
update=1

if [ ! -d "$userdir" ]; then
  mkdir "$userdir"
  update=0
else
  cp -R $userdir $userdirbak
  update=1
fi

cd "$userdir"
(cd "$dfdir"; find -type d ! -name .) |xargs mkdir -p

cd "$userdir"
for file in `find $dfdir -type f`
do
    dfdir_path=$(dirname $file)
    user_path="${dfdir_path/$dfdir/$userdir}"
    cd "$user_path"
    ln  $dfdir_path/$(basename $file)
done

chmod -R 755 "$user_path"

#then delete saved games
rm -r "$userdir/data/save"
mkdir "$userdir/data/save"

if [ "${update}" = "0" ]; then
  #only copy default world if not update
  cp -R $dfdir/data/save/region1 $userdir/data/save/

  #delete the gamelog.txt then touch the new one
  rm -r "$userdir/gamelog.txt"
  touch "$userdir/gamelog.txt"

  #do a regular copy of the data/init/init.txt file
  rm "$userdir/data/init/*"
  cp "$dfdir/data/init/*" "$userdir/data/init/"

else
  cp -R $userdirbak/data/save $userdir/data/save/
  cp -R $userdirbak/gamelog.txt $userdir/gamelog.txt
  cp $userdirbak/data/init/* $userdir/data/init/
fi

cp "$dflauncher" "$userdir/df-launch.sh"

#use sed to replace XXXXXX with $user in dwizzell.pl and save it there.
sed "s/|df_XXXXXX/|df_${user}/g" $dwizzell |\
sed "s/df_XXXXXX/${major_version}\/df_${user}/g" > "$userdir/dwizzell.pl" 

#check to see if we have enough open slots
num_current_games=`ls -1 ${inprogressdir} |wc -l`

if [ "${num_current_games}" -gt "${MAXGAMES}" ]; then
   exec /bin/too-many-df-games.sh
else
   #now run the game
   cd "$userdir"
   exec "$userdir/df-launch.sh"
   #exec strace -v -s 4096 -ff -o /tmp/traces/trace.$$. $userdir/df 
fi


