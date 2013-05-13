##### ---  cron-job set for different scheduler activities like  ##### ---

# 1. Every day 9:50 pm passwords should be regenerated for all users except - 'super_admin' and 'admin'
# 2. All these generated passwords should be expired at 4.00 am every_day basis.
# 3. Data purging functionality on every 2 day basis
# 4. At application - all caches , logs and sessions should be clean - on every Friday morning
# 5. After server reboot application should also  restart


every  1.day, :at => "9.50pm" do
  rake "password_reset:for_users"
end


every 1.day, :at=> '1am'  do
  rake "password_reset:for_users_expired"
end

every :friday, :at=> '8.30am'  do
#  command "find /home/UpCCndM9Q/shivraj_backup/ -type f -mtime +3 -exec rm {} \;"
#  command "find /home/UpCCndM9Q/anand_backup/ -type f -mtime +3 -exec rm {} \;"
end

every 2.day, :at => "5am" do
  rake ":purge_data:auto"
end


every :friday, :at => "4am" do
  rake "log:clear"
  rake "tmp:clear"
#  exec  "rm -rf #{RAILS_ROOT}/tmp/cache"
end


every :reboot do
#  exec "ruby script/server -e production -d"
end
