#!/usr/sbin/dtrace -s

#pragma D option quiet

/*
 * smbmon.d
 *
 * Monitor SMB read/write performance.
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

sdt:smbsrv::-smb_op-Read-start,
sdt:smbsrv::-smb_op-Write-start
{
    self->start = timestamp;
}

sdt:smbsrv::-smb_op-Read-done
/self->start/
{
    self->rw_param = (smb_rw_param_t *)arg1;

    @r_latency = avg((timestamp - self->start) / 1000);
    @r_bs      = avg(self->rw_param->rw_count);
    @r_bytes   = sum(self->rw_param->rw_count);
    @r_count   = count();

    self->start = 0;
}

sdt:smbsrv::-smb_op-Write-done
/self->start/
{
    self->rw_param = (smb_rw_param_t *)arg1;

    @w_latency = avg((timestamp - self->start) / 1000);
    @w_bs      = avg(self->rw_param->rw_count);
    @w_bytes   = sum(self->rw_param->rw_count);
    @w_count   = count();

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
