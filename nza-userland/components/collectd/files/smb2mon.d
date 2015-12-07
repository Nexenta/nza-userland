#!/usr/sbin/dtrace -s

#pragma D option quiet

/*
 * smb2mon.d
 *
 * Monitor SMB2 read/write performance.
 *
 * Copyright (c) 2014  Nexenta Systems
 * William Kettler <william.kettler@nexenta.com>
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

    @r_bs    = avg(args[0]->sr_req_length);
    @r_bytes = sum(args[0]->sr_req_length);
    @r_count = count();
}

fbt:smbsrv:smb2_write:entry
{
    self->start = timestamp;

    @w_bs    = avg(args[0]->sr_req_length);
    @w_bytes = sum(args[0]->sr_req_length);
    @w_count = count();
}

fbt:smbsrv:smb2_read:return
/self->start/
{
    @r_latency = avg((timestamp - self->start) / 1000);

    self->start = 0;
}

fbt:smbsrv:smb2_write:return
/self->start/
{
    @w_latency = avg((timestamp - self->start) / 1000);

    self->start = 0;
}

profile:::tick-1sec
{
    secs--;
}

profile:::tick-1sec
/secs == 0/
{
    printa("%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d\n",
            @r_latency, @r_bs, @r_bytes, @r_count,
            @w_latency, @w_bs, @w_bytes, @w_count);

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
