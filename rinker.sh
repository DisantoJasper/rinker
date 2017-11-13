################ Script Variables ###############################
IPPATH=/var/log/IP # IP address storage file
TMPIP=/tmp/tmpIP # Temp IPstorage file 
LOGPATH=/var/log/changeip.log # Log file
TEMP=/tmp/temp #Temp storage file 
CIPUSER= # ChangeIP.com Username 
CIPPASS= #ChangeIP.com Password 
CIPSET=1 # ChangeIP.com recordset 
LOGLEVEL=2 #0=off,1=normal,2=verbose 
LOGMAX=500 # Max log lines, 0=unlimited
#################################################################
# get current IP from ip.changeip.com, and store in $TEMP
wget -q -U "rinker.sh wget 1.0" -O $TEMP ip.changeip.com
# parse $TEMP for the ip, and store in $TMPIP
grep IPADDR < $TEMP | cut -d= -s -f2 | cut -d- -s -f1 > $TMPIP
# compare $IPPATH with $TMPIP, and if different, execute update
if diff $IPPATH $TMPIP > /dev/null
  then # same IP, no update
      if [ $LOGLEVEL -eq 2 ]
        then # if verbose, log no change
          echo "--------------------------------" >> $LOGPATH
          date >> $LOGPATH
          echo "No Change" >> $LOGPATH
          echo -e "IP: \c" >> $LOGPATH
          cat $IPPATH >> $LOGPATH
      fi
  else # different IP, execute update
      wget -q -U "rinker.sh wget 1.0" -O $TEMP --http-user=$CIPUSER 
--http-password=$CIPPASS 
"https://nic.changeip.com/nic/update?cmd=update&set=$CIPSET"
      if [ $LOGLEVEL -ne 0 ]
        then # if logging, log update
          echo "--------------------------------" >> $LOGPATH
          date >> $LOGPATH
          echo "Updating" >> $LOGPATH
          echo -e "NewIP: \c" >> $LOGPATH
          cat $TMPIP >> $LOGPATH
          if [ $LOGLEVEL -eq 2 ]
            then # verbose logging
              echo -e "OldIP: \c" >> $LOGPATH
              cat $IPPATH >> $LOGPATH
              cat $TEMP >> $LOGPATH # log the ChangeIP.com update reply
          fi
      fi
      cp $TMPIP $IPPATH # Store new IP fi
# if $LOGMAX not equal to 0, reduce log size to last $LOGMAX number of 
# lines
if [ $LOGMAX -ne 0 ]
  then
      tail -n $LOGMAX $LOGPATH > $TEMP
      cp $TEMP $LOGPATH
fi
