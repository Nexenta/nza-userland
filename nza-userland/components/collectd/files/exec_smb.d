#!/usr/sbin/dtrace -s

#pragma D option quiet

/*
 * smb.d
 *
 * Monitor SMB read/write performance.
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

sdt:smbsrv::-smb_op-Read-start,
sdt:smbsrv::-smb_op-Write-start
{
    self->start = timestamp;
}

sdt:smbsrv::-smb_op-Read-done
/self->start/
{
    self->rw_param = (smb_rw_param_t *)arg1;

    @r_latency["r_latency", INTERVAL] = avg((timestamp - self->start) / 1000);
    @r_bs["r_bs", INTERVAL]           = avg(self->rw_param->rw_count);
    @r_bytes["r_bytes", INTERVAL]     = sum(self->rw_param->rw_count);
    @r_count["r_count", INTERVAL]     = count();

    self->start = 0;
}

sdt:smbsrv::-smb_op-Write-done
/self->start/
{
    self->rw_param = (smb_rw_param_t *)arg1;

    @w_latency["w_latency", INTERVAL] = avg((timestamp - self->start) / 1000);
    @w_bs["w_bs", INTERVAL]           = avg(self->rw_param->rw_count);
    @w_bytes["w_bytes", INTERVAL]     = sum(self->rw_param->rw_count);
    @w_count["w_count", INTERVAL]     = count();

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
