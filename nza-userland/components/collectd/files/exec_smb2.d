#!/usr/sbin/dtrace -s

#pragma D option quiet

/*
 * smb2.d
 *
 * Monitor SMB2 read/write performance.
 *
 * Copyright (c) 2016  Nexenta Systems
 * William Kettler <william.kettler@nexenta.com>
 *
 * Version 0.1.0
 * January 13, 2016
 *
 */

inline int INTERVAL = $1;

dtrace:::BEGIN
{
    secs = INTERVAL;
}

fbt:smbsrv:smb2_read:entry
{
    self->start = timestamp;

    @r_bs["r_bs", INTERVAL]       = avg(args[0]->sr_req_length);
    @r_bytes["r_bytes", INTERVAL] = sum(args[0]->sr_req_length);
    @r_count["r_count", INTERVAL] = count();
}

fbt:smbsrv:smb2_write:entry
{
    self->start = timestamp;

    @w_bs["w_bs", INTERVAL]       = avg(args[0]->sr_req_length);
    @w_bytes["w_bytes", INTERVAL] = sum(args[0]->sr_req_length);
    @w_count["w_count", INTERVAL] = count();
}

fbt:smbsrv:smb2_read:return
/self->start/
{
    @r_latency["r_latency", INTERVAL] = avg((timestamp - self->start) / 1000);

    self->start = 0;
}

fbt:smbsrv:smb2_write:return
/self->start/
{
    @w_latency["w_latency", INTERVAL] = avg((timestamp - self->start) / 1000);

    self->start = 0;
}

profile:::tick-1sec
{
    secs--;
}

profile:::tick-1sec
/secs == 0/
{
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @r_bs);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @r_bytes);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @r_count);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @r_latency);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @w_bs);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @w_bytes);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @w_count);
    printa("PUTVAL \"smb/smb2/gauge-%s\" interval=%i N:%@d\n", @w_latency);

    clear(@r_latency);
    clear(@r_bs);
    clear(@r_bytes);
    clear(@r_count);
    clear(@w_latency);
    clear(@w_bs);
    clear(@w_bytes);
    clear(@w_count);

    secs = INTERVAL;
}
