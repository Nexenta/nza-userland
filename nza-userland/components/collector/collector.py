#!/usr/bin/env python

"""Nexenta Information Collector:
This script collects files, logs, or command outputs as directed by
the specified configuration file and either compiles the results up
in a single compressed Tar archive or takes the results and compares
them to a specified directory to keep an 'up to date' picture in that
directory by updating its files where appropriate with each run.

This script is PyDoc compliant -- run "pydoc ./Collector.py" for a
PyDoc-generated man page."""

# import necessary modules - none of these can be skipped
import getopt
import sys
import os
import signal
import simplejson
import subprocess
import time
import re
import shutil
import unicodedata
import filecmp
from threading import Thread

try:
    from Queue import Queue
except ImportError:
    from queue import Queue     # deal with version differences of Python
                                # between NexentaStor releases

tmpworkdir = "/tmp/collector_wd"
tmpoutput = "/tmp/collector-" + str(os.getpid())
# globals - modify at own risk; some of these can be modified
# via command-line arguments, which is safe; those have been noted
output_dir = tmpoutput + "/"                # modifiable via cmd-line, changes
                                            # here will be ignored!
output_file = tmpoutput + ".tar.gz"         # modifiable via cmd-line, changes
                                            # here will be ignored!
config_file = "/etc/collector.conf"         # modifiable via cmd-line
working_dir = tmpworkdir + "/"              # modifiable via cmd-line
verbose = False                             # modifiable via cmd-line
silent = False                              # modifiable via cmd-line
destroy_output_dir = True                   # modifiable via cmd-line
num_worker_threads = 8                      # modifiable via cmd-line

# do not edit below this line
q = Queue()
license = "unknown"
machine_id = "unknown"
app_ver = "unknown"
coll_ver = "0018"
cmd_init = 0
cmd_run = 0
cmd_success = 0
cmd_terminate = 0
output_dir_set = False
output_file_set = False
working_dir_set = False
stuff_to_do = False
script_started = None
script_ended = None
no_touch = False

def usage(input):
    """Usage text - displayed to command line when -h is called or an invalid
        command line option is specified."""

    if input:
        print "Error: " + input

    print "Collector.py:"
    print "Nexenta log collection script - grabs various system files, log"
    print "files, SQLite DB query results and the output from a variety of"
    print "diagnostic commands, whatever it is asked to, and will either place"
    print "it all in a tarball if requested, or by default will compare the"
    print "results to an existing directory from previous run(s) and update"
    print "in place any output that has changed (or touch the file of any"
    print "output that has not changed (configurable with --no-touch)."
    print ""
    print "Command line options:"
    print "    --output-dir:    Specifies the directory to use for"
    print "                         output. Script will refuse to run if"
    print "                         it determines the destination has"
    print "                         insufficient free space for the task."
    print "                         Defaults to: /tmp/collector-{PID}/"
    print "    --output-file:   Specifies the filename for the final"
    print "                         tarball created by the script."
    print "                         [Setting this flag makes the collector"
    print "                         generate a tarball of results.]"
    print "                         Defaults to: /tmp/collector-{PID}.tar.gz"
    print "    --working-dir:   Specifies the working directory that"
    print "                         the script should compare its output"
    print "                         against. It will update files with"
    print "                         new versions if they are not identical,"
    print "                         or will touch the file already in the"
    print "                         working-dir if the new output is"
    print "                         identical. [This will cause the script"
    print "                         to not create any tarball - this option"
    print "                         is mutually exclusive to -f, and both"
    print "                         cannot be set at the same time.]"
    print "                         Defaults to: /tmp/collector_wd/"
    print "    --config:        Specifies the JSON-encoded config file"
    print "                         to use."
    print "                         Defaults to: /etc/collector.conf."
    print "    --num-threads:   Set the number of worker threads to"
    print "                         run simultaneously. Setting this to 1"
    print "                         effectively tells this script to run"
    print "                         in a serial mode. Default: 8"
    print "    -t, --no-touch:  Choose this to disable touching files in"
    print "                         the working directory if the output of"
    print "                         this run is identical."
    print "    -v, --verbose:   Turns on verbose output to STDOUT. Not"
    print "                         recommended except for debugging purposes."
    print "    -h, --help:          Produces this help screen."

def get_appliance_info():
    """Attempts to get licensing information out of the appliance."""

    global license
    global machine_id
    global app_ver

    # not using 'with' because 3.0 uses Python 2.5, not 2.6
    try:
        f = open("/var/lib/nza/nlm.key", "r")

        # this method should future-proof us a little if nlm.key
        # changes
        for line in f:
            if re.match('([A-Z0-9]*)-([A-Z0-9]*)-([A-Z0-9]*)-([A-Z0-9]*)', line):
                m = re.search('([A-Z0-9]*)-([A-Z0-9]*)-([A-Z0-9]*)-([A-Z0-9]*)', line)
                license = m.group(0)
                machine_id = m.group(3)

        f.close()
    except:
        print "Error occurred detecting Nexenta license key. Is this a " \
                "NexentaStor appliance? Aborting!"
        sys.exit(1)

    try:
        f = open("/etc/issue", "r")

        for line in f:
            if re.match('^Open', line):
                app_ver = line.strip()

    except:
        print "Error occurred detecting Nexenta version. Aborting!"
        sys.exit(1)

def prepare_working_dir(groups):
    """Prepares the output directory and verifies working directory if applicable."""

    global output_dir
    global working_dir
    global working_dir_set

    if os.path.exists(output_dir):
        print "Output directory appears to exist! Cannot run if output " \
                "directory already exists."
        sys.exit(1)

    try:
        os.mkdir(output_dir)
    except:
        print "Error occurred while creating output directory, check " \
                "permissions and try again."
        sys.exit(1)

    for group in groups:
        try:
            os.mkdir(output_dir + group)
        except:
            print "Error occurred populating output directory structure, " + \
                    "check permissions and try again."
            sys.exit(1)

    if working_dir_set == True:
        if not os.path.exists(working_dir):
            try:
                os.mkdir(working_dir)
            except:
                print "Error occurred while creating working directory, check " \
                        "permissions and try again."
                sys.exit(1)

        for group in groups:
            if not os.path.exists(working_dir + group):
                try:
                    os.mkdir(working_dir + group)
                except:
                    print "Error occurred populating working directory structure, " + \
                            "check permissions and try again."
                    sys.exit(1)

def parse_cmd_line():
    """Parses the command line arguments using getopt."""

    global output_dir
    global working_dir
    global config_file
    global destroy_output_dir
    global silent
    global output_file
    global output_file_set
    global working_dir_set
    global verbose
    global num_worker_threads
    global no_touch

    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:c:vfwxstn:", \
                                   ["help", "output-dir=", "config=", \
                                   "verbose", "output-file=", "working-dir=", \
                                   "no-destroy-output-dir", "silent", "no-touch"\
                                   "num-threads="])
    except getopt.GetoptError, err:
        print str(err)
        usage("")
        sys.exit(1)

    for opt, arg in opts:
        if opt in ("-v", "--verbose"):
            verbose = True
        elif opt in ("-h", "--help"):
            usage("")
            sys.exit(1)
        elif opt in ("--output-dir"):
            output_dir = arg + "/"
            output_dir_set = True
        elif opt in ("--output-file"):
            output_file = arg
            output_file_set = True
        elif opt in ("--working-dir"):
            working_dir = arg + "/"
            working_dir_set = True
        elif opt in ("--config"):
            config_file = arg
        elif opt in ("-s", "--silent"):
            silent = True
        elif opt in ("--num-threads"):
            num_worker_threads = int(arg)
        elif opt in ("-x", "--no-destroy-output-dir"):
            destroy_output_dir = False
        elif opt in ("-t", "--no-touch"):
            no_touch == True
        else:
            assert False, "unhandled option"

    if output_file_set == True and working_dir_set == True:
        usage("Invalid configuration -- cannot specify -f and -w together, functionality mutually exclusive.")
        sys.exit(1)

    if output_file_set == False and working_dir_set == False:
        # we must have one or the other, default to working directory
        working_dir_set = True

def sanitize_file_label(label):
    """Sanitizes file-label variables to not include characters that aren't acceptable in a filename."""

    tmp = unicode(label, 'ascii')
    tmp = unicodedata.normalize('NFKD', \
                                tmp).encode('ascii', 'ignore')

    tmp = unicode(re.sub('[^\w\s-]', '', tmp).strip().lower())
    tmp = unicode(re.sub('[-\s]+', '-', tmp))

    return tmp

def parse_config_file():
    """Parses the config file - expects a single large JSON
       file it can convert to a nested dictionary."""

    global config_file
    global stuff_to_do

    try:
        fp = open(config_file)
    except IOError:
        print "Error opening config file:", config_file
        sys.exit(1)

    try:
        stuff_to_do = simplejson.load(fp, encoding=None, cls=None,
                                      object_hook=None)
    except:
        print "Error reading config file:", config_file
        sys.exit(1)

class Alarm(Exception):
    pass

def alarm_handler(signum, frame):
    raise Alarm

def process(command):
    """Handles creating a sub process and returns the subprocess.Popen
       object.

        command  (string)    command to run in shell subprocess"""

    proc = subprocess.Popen(command,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            shell=True)

    return proc

def compare_and_update(output_dir, working_dir, groups):
    """Compare output directory of this run to specified working
    directory. Any time output directory contains a file that
    does not exist, move to working directory. Any time file
    exists in both locations, compare, and if match just touch
    the file in working directory; if not match, move output
    directory version over."""

    global verbose
    global no_touch

    moved = 0
    touched = 0

    # we iterate per group
    for group in groups:
        left_dir = output_dir + group
        right_dir = working_dir + group
        dirc = filecmp.dircmp(left_dir, right_dir)

        # move over any file that simply does not exist in working dir
        for file in dirc.left_only:
            if verbose == True:
                print "File exists only in output_dir, adding to working_dir: " + file

            moved += 1
            shutil.move(left_dir + "/" + file, right_dir + "/" + file)

        for file in dirc.common:
            if not filecmp.cmp(left_dir + "/" + file, right_dir + "/" + file, shallow=False):
                if verbose == True:
                    print "Common file found to not compare, replacing: " + file

                moved += 1
                shutil.move(left_dir + "/" + file, right_dir + "/" + file)
            else:
                # update timestamp ("touch") working_dir file
                if verbose == True and no_touch == False:
                    print "Common file is identical, updating timestamp: " + file

                if verbose == True and no_touch == True:
                    print "Common file is identical, but no touch is enabled, doing nothing: " + file

                touched += 1

                if no_touch == False:
                    os.utime(right_dir + "/" + file, None)

    output = [moved, touched]

    return output

class Command(object):
    """This class represents each command we're going to perform."""
    
    global output_dir
    global verbose
    global silent
    global license
    global machine_id
    global app_ver
    global cmd_run
    global cmd_init
    global cmd_success
    global cmd_terminate

    def __init__(self, item):
        """Initialization routines - we need to figure out what we are,
        figure out what command we're running, set a timeout for our
        command and so on."""

        global cmd_init

        self.group = item[0]
        self.cmd = item[1]
        self.args = item[2]
        self.type = self.args["type"]

        self.status = "initialized"
        self.terminated = False

        # accounting
        cmd_init = cmd_init + 1

        # deal with setup based on "type" of command, currently recognizes
        # file
        # command
        # log

        # file understands 'timeout'
        if self.type == "file":
            self.cmd_line = "cp " + str(self.cmd) + " " + \
                    output_dir + self.group + "/"

            if not self.args.has_key("timeout"):
                self.args["timeout"] = 600

        # command understands 'gzip' and 'timeout', but 'gzip' logic is
        # done later
        elif self.type == "cmd":
            self.cmd_line = str(self.cmd)

            if not self.args.has_key("timeout"):
                self.args["timeout"] = 300

            # commands need a file-label - it's important in this code
            # and necessary; if someone forgot it in the conf file,
            # create a decent (and hopefully safe) one here
            if not self.args.has_key("file-label") or self.args["file-label"] == "":
                self.args["file-label"] = sanitize_file_label(self.cmd_line)

        elif self.type == "nmc":
            # currently we do not support NMC commands, and we may never do so, but it is a valid
            # type so let's accept and ignore it
            a=1

        else:
            if silent == False:
                print "Unknown item type found in queue, panicking! (" + str(self.type) + ")"

            sys.exit(1)

        self.timeout = self.args["timeout"]

    def run(self, timeout):
        """Called by worker thread to begin actual command run.
        This function launches a subprocess that runs the command line
        set for the object. If the command contains a file-label variable,
        it also sets up files for STDERR and STDOUT and tells subprocess
        to pipe to those files.

        This function creates a thread to handle the running of the
        subprocess in order to deal with timeouts despite the lack
        of subprocess timeout functionality in the Python bundled
        with NexentaStor 3.0. The function will wait the specified
        timeout and if the subprocess is still running, SIGKILL will
        be sent to it."""

        global cmd_success
        global cmd_terminate

        def target():
            """Function invoked by run() as a thread."""

            global cmd_run

            # for pipes we don't want the output from
            DEVNULL = os.open(os.devnull, os.O_RDWR)

            if silent == False and verbose == True:
                print "Started \"" + str(self.cmd_line) + "\" via run()."

            if self.args.has_key("file-label") and self.args["file-label"] != "":
                filestub = output_dir + self.group + "/" + \
                        self.args["file-label"]

                # if we're gzipping, we don't care about stdout as it's
                # being piped around already - can still capture stderr
                # so we do
                if self.args.has_key("gzip") and self.args["gzip"] == True:
                    self.cmd_line = self.cmd_line + " | gzip -c > " + \
                            filestub + ".out.gz"

                    self.err_f = open(filestub + ".err", "w")

                    self.process = subprocess.Popen(self.cmd_line,
                                                    stdout=DEVNULL,
                                                    stderr=self.err_f,
                                                    shell=True)

                # regular run -- capture stdout and stderr to file
                else:
                    self.out_f = open(filestub + ".out", "w")
                    self.err_f = open(filestub + ".err", "w")
                    self.process = subprocess.Popen(self.cmd_line,
                                                    stdout=self.out_f,
                                                    stderr=self.err_f,
                                                    shell=True)

            # pipe stdout and stderr to /dev/null as this is a
            # cp command and nobody cares (we know success or failure
            # implicitly by rather it ends up in the result data or not)
            else:
                self.process = subprocess.Popen(self.cmd_line,
                                                stdout=DEVNULL,
                                                stderr=DEVNULL,
                                                shell=True)

            self.status = "running"
            self.started_at = time.time()

            # accounting
            cmd_run = cmd_run + 1

            # this is where we actually DO the command we set up above
            self.output = self.process.communicate()

            # deal with file closure
            if self.args.has_key("file-label") and self.args["file-label"] != "":
                if self.args.has_key("gzip") and self.args["gzip"] == True:
                    self.err_f.close()
                else:
                    self.out_f.close()
                    self.err_f.close()

            self.status = "completed"
            self.ended_at = time.time()

        # this is where we actually DO all the stuff we did above - we defined
        # a target function but it is only at this point that it is called
        # in execution
        worker_thread = Thread(target=target)
        worker_thread.start()

        # now we block-wait this thread for 'timeout' seconds, waiting on
        # the "sub"-thread we just launched with the subprocess inside
        worker_thread.join(timeout)

        # if we're here, the join() has let us get here - we are either
        # here because 'timeout' was met, or because the thread terminated
        # on its own successfully -- let's find out
        if worker_thread.isAlive():
            # if we're here, we got here because the join() above met
            # its timeout and the "sub"-thread is still alive - we need
            # to get rid of it

            # self.process.terminate()
            # can't use the above function, as our Python in NexentaStor3.x 
            # does not yet support this flag, so we must do the dirtier method
            # below - could be fixed by verifying Python version at some
            # future date, but right now only Python 2.5.5 is out there anyway
            self.terminated = True
            self.terminated_at = time.time()

            os.kill(self.process.pid, signal.SIGKILL)

        # we just potentially tried to os.kill the worker thread - let's
        # rejoin it again until it's gone; so far this has never caused
        # an issue but if we should ever have a hung Collector, I'd start
        # by looking here -- and potentially improving this to do another
        # timeout wait followed by a global panic because we can't seem
        # to get rid of our "sub"-thread
        worker_thread.join()

        # accounting details
        if self.terminated == True:
            self.status = "terminated"
            self.ended_at = self.terminated_at
            cmd_terminate = cmd_terminate + 1

            # deal with file closures        
            if self.args.has_key("file-label") and self.args["file-label"] != "":
                if self.args.has_key("gzip") and self.args["gzip"] == True:
                    self.err_f.close()
                else:
                    self.out_f.close()
                    self.err_f.close()
        else:
            cmd_success = cmd_success + 1
            self.ended_at = time.time()

        if silent == False and verbose == True:
            print "Completed \"" + str(self.cmd_line) + "\" with status " + \
                    str(self.status) + " in " + \
                    str(self.ended_at - self.started_at) + " seconds."

        if self.args.has_key("file-label") and self.args["file-label"] != "":
            # file label should only exist for COMMANDS -- files and logs
            # will just skip this since they never have file-label set
            filestub = output_dir + self.group + "/" + \
                    self.args["file-label"]

            # make sure we cleaned up file handles
            if self.args.has_key("gzip") and self.args["gzip"] == True:
                if not self.err_f.closed:
                    self.err_f.close()
            else:
                if not self.out_f.closed:
                    self.out_f.close()

                if not self.err_f.closed:
                    self.err_f.close()

            # write out the statistics gathered for this command run
            # skip this if doing a working_dir run
            if working_dir_set == False:
                f = open(filestub + ".stats", "w")
    
                ofile = "Command line run: " + self.cmd_line + "\n"
                ofile = ofile + "Command completion status: " + self.status + "\n"

                if self.status == "completed":
                    ofile = ofile + "Command return code: " + \
                            str(self.process.returncode) + "\n"
                else:
                    ofile = ofile + "Command return code: unavailable\n"

                ofile = ofile + "Started at: " + \
                        time.ctime(self.started_at) + "\n"
                ofile = ofile + "Ended at: " + \
                        time.ctime(self.ended_at) + "\n"
                ofile = ofile + "Elapsed (s): " + \
                        str(self.ended_at - self.started_at) + "\n"
                ofile = ofile + "License Key: " + license + " [" + app_ver + "]\n"

                f.write(ofile)
                f.close()
        else:
            # no file label? should be a file type, so do nothing
            a=1 # sigh Python

def worker():
    """This is the simple worker thread spawned by the main routine
    when this script is run. Each worker thread will watch the queue
    and grab stuff out of it, construct a Command object from the
    data, and then let that Command object run. Once complete, note
    that our task is done and repeat."""

    global q
    global silent

    # loop - continue until q.empty() returns True
    while not q.empty():

        donothing = False

        # try to snag an item from the queue - it is possible that
        # we got here but before we can snag an item, another worker
        # thread will catch the last item so we'll end up finding
        # nothing - thus the try/except block -- if we find nothing, we
        # hit the except, which will set 'donothing' -- if 'donothing' is
        # true we'll not try to do anything this loop iteration and just
        # loop again (which should, in theory, hit q.empty() = True and
        # we'll be done
        try:
            item = q.get(block=False, timeout=1)
        except:
            donothing = True

        if donothing == False:
            proc_item = Command(item)
            proc_item.run(proc_item.timeout)
        
            q.task_done()

        if silent == False and verbose == False:
            sys.stdout.write(".")
            sys.stdout.flush()

    return True

def main():
    """Main processing loop - will initiate the script, check command
       line options, load in the config file, set up the output directory
       and then initiate all the actions in priority order and then
       sit, mothering the subprocess calls until either all are completed
       or timed out & killed.
       
       Final processing involves writing out the results of all the
       processes to the appropriate places, tarballing up the output
       directory, and cleaning up after."""

    global verbose
    global stuff_to_do
    global script_started
    global script_ended
    global num_worker_threads
    global q
    global output_dir
    global output_file
    global output_dir_set
    global output_file_set
    global working_dir_set
    global std_out
    global std_err
    global license
    global machine_id
    global app_ver
    global coll_ver
    global cmd_init
    global cmd_run
    global cmd_success
    global cmd_terminate

    x = 1
    script_started = time.time()        # for accounting purposes

    parse_cmd_line()    # does what it sounds like
    parse_config_file()  # same deal
    get_appliance_info()   # determine license key of box

    # IF nobody set a output directory or file, let's get rid of the
    # simplistic PID default and replace with license key and
    # ISO format date/time
    tmpoutput = "/tmp/collector-"

    if output_dir_set == False:
        output_dir = tmpoutput + machine_id + "." + \
                str(time.strftime("%Y-%m-%d.%H-%M-%S%Z")) + "/"

    if output_file_set == False:
        output_file = tmpoutput + machine_id + "." + \
                str(time.strftime("%Y-%m-%d.%H-%M-%S%Z")) + ".tar.gz"

    if silent == False:
        print "Collector starting @ " + time.ctime(script_started)

    if silent == False:
        print "Creating collection queue..",

    # this prepares the Queue for ingestion by the worker threads -
    # it fills the queue based on priority level, re-looping from 1 to 99
    # and inserting as it goes
    #
    # TODO - potentially this is where we should filter by group from
    # a list coming from command line if we want to limit results to
    # specific groups -- one could also, in theory, limit to 'above', 'below'
    # or 'exactly' a priority level as well, for further exclusion
    #
    # as a side-effect of how this currently operates, setting a priority
    # level of 0 or > 99 OR not setting priority at all will cause that
    # command in the config file to be skipped; a good way to include entries
    # you don't yet want Collector to run
    groups = []

    while (x < 100):
        for group, item in stuff_to_do.iteritems():
            for flag, value in item.iteritems():
                if value.has_key("priority") and int(value["priority"]) == x:
                    if group not in groups:
                        groups.append(group)

                    if value.has_key("enabled") and value["enabled"] != False:
                        q.put([group, flag, value])

                    if silent == False and verbose == True:
                        print "Queued: [group: " + str(group) + "] " + \
                                "[priority: " + str(value["priority"]) + \
                                "] [type: " + str(value["type"]) + "] " + \
                                str(flag)

        x = x + 1

    if silent == False:
        print "done. " + str(q.qsize()) + " commands in queue."
        print "Preparing output directory (" + output_dir + ")",

        if working_dir_set == True:
            print "& working directory (" + working_dir + ")",
        
        print "..",

    # create working directory structure based on groups
    prepare_working_dir(groups)

    if silent == False:
        print "done."

    if silent == False:
        print "Beginning command run @ " + time.ctime(time.time()) + "."

    # initialize the worker threads - since the queue is populated they
    # will immediately begin eating through it
    for i in range(num_worker_threads):
        if silent == False and verbose == True:
            print "Creating worker thread # " + str(i)

        t = Thread(target=worker)
        t.start()

    if silent == False and verbose == False:
        print "Progress (do not be alarmed by long, possibly minute+ pauses): ",

    # wait for all to complete, or timeout if 15 minutes elapsed
    signal.signal(signal.SIGALRM, alarm_handler)
    signal.alarm(15*60) # 15 minutes

    try:
        q.join()
        signal.alarm(0)
    except Alarm:
        if silent == False:
            print "Script has run for maximum timeout and is still running."
            print "Something has gone wrong!"

        sys.exit(1)

    if silent == False:
        if verbose == False:
            print ""

        print "Command run completed @ " + time.ctime(time.time()) + "."

        if working_dir_set == False:
            print "Packaging results..",
        else:
            print "Comparing results to working directory..",

    # time as of script end but before tarring - accounting purposes
    script_ended = time.time()

    # let us create a collector statistics file with various runtime
    # stats we collected
    # pointless if we're a working_dir comparison run
    if working_dir_set == False:
        f = open(output_dir + "/collector.stats", "w")

        ofile = "Collector (" + coll_ver + ") Run Stats\n"
        ofile = ofile + "Script started: " + time.ctime(script_started) + "\n"
        ofile = ofile + "Script ended: " + time.ctime(script_ended) + "\n"
        ofile = ofile + "Elapsed (s): " + str(script_ended - script_started) + "\n"
        ofile = ofile + "Number of workers: " + str(num_worker_threads) + "\n"
        ofile = ofile + "Commands (init/run/success/terminate): " + \
                str(cmd_init) + "/" + str(cmd_run) + "/" + str(cmd_success) + \
                "/" + str(cmd_terminate) + "\n"
        ofile = ofile + "Appliance version: " + app_ver + "\n"
        ofile = ofile + "License key: " + license + "\n"
    
        # add the size of the working directory pre-tar to the stats file
        duproc = process("du -sh " + output_dir + " | cut -f1")
        tmpoutput = duproc.communicate()

        dirsize = tmpoutput[0].strip()

        ofile = ofile + "Working directory size: " + str(dirsize) + "\n"

        f.write(ofile)
        f.close()

    # tar/gzips the output directory if output_file specified
    if output_file_set == True:
        tarproc = process("tar -czvf " + output_file + " " + output_dir)
        tarproc.communicate()

        # md5sum the tarball and create .md5 file - this will let us verify
        # transfer integrity on the remote end later
        md5proc = process("md5sum " + output_file + " > " + output_file + \
                          ".md5")
        md5proc.communicate()

    if working_dir_set == True:
        compare_and_update(output_dir, working_dir, groups)

    if silent == False:
        print "done."
        print "Cleaning up output area (" + output_dir + ")..",

    # removes the output directory (if you were to put the output
    # file in the output directory this'd be bad)
    if destroy_output_dir == True:
        rmproc = process("rm -rf " + output_dir)
        rmproc.communicate()

    if silent == False:
        print "done."

    # reset script_ended for after tarring for print output if requested
    script_ended = time.time()

    if silent == False:
        print "Collector finished @ " + time.ctime(script_ended) + ". "
        print "Elapsed time: " + \
                str(round((script_ended - script_started),2)) + \
                " seconds."
        if working_dir_set == False:
            print "Collection results file: " + output_file

    sys.exit(0)
        
# pydoc related
if __name__ == "__main__":
    main()

# pydoc related
__author__          = "Andrew Galloway"
__copyright__       = "Copyright (c) 2011 Nexenta Systems, Inc"
__credits__         = ["Andrew Galloway", "Sam Zaydel", "Craig Morgan"]
__license__         = "dunno yet"
__version__         = "$Revision: " + coll_ver + " $"
__created_date__    = "$Date: 2011-05-31 13:32:01 +0600 (Tue, 31 May 2011) $"
__last_updated__    = "$Date: 2012-03-06 17:00:00 +0600 (Wed, 21 Sep 2011) $"
__maintainer__      = "Andrew Galloway"
__email__           = "andrew.galloway@nexenta.com"
__status__          = "Beta"
