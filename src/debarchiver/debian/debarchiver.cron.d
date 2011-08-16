#
# Regular cron jobs for the debarchiver package
#
# Run the archiver every five minutes.
*/5 * * * *	debarchiver	test -x /usr/bin/debarchiver && /usr/bin/debarchiver -so | logger -t debarchiver -p daemon.info
