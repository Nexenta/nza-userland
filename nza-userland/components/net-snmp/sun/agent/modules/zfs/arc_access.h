/*
 * This file and its contents are supplied under the terms of the
 * Common Development and Distribution License ("CDDL"), version 1.0.
 * You may only use this file in accordance with the terms of version
 * 1.0 of the CDDL.
 *
 * A full copy of the text of the CDDL should have accompanied this
 * source.  A copy of the CDDL is also available via the Internet at
 * http://www.illumos.org/license/CDDL.
 */

/*
 * Copyright 2013 Nexenta Systems, Inc.  All rights reserved.
 */

#ifndef _ARCSTAT_ACCESS_H
#define	_ARCSTAT_ACCESS_H

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum arc_table_col {
	ARC_TC_INST = 1,
        ARC_TC_META_USED,
        ARC_TC_C,
        ARC_TC_P,
        ARC_TC_SIZE,
        ARC_TC_L2_SIZE_LOW,
        ARC_TC_L2_SIZE_HIGH,
        ARC_TC_HITS,
        ARC_TC_MISSES,
        ARC_TC_DEMAND_DATA_HITS,
        ARC_TC_DEMAND_DATA_MISSES,
        ARC_TC_DEMAND_METADATA_HITS,
        ARC_TC_DEMAND_METADATA_MISSES,
        ARC_TC_PREFETCH_DATA_HITS,
        ARC_TC_PREFETCH_DATA_MISSES,
        ARC_TC_PREFETCH_METADATA_HITS,
        ARC_TC_PREFETCH_METADATA_MISSES,
        ARC_TC_MFU_GHOST_HITS,
        ARC_TC_MFU_HITS,
        ARC_TC_MRU_GHOST_HITS,
        ARC_TC_MRU_HITS,
        ARC_TC_L2_HITS,
        ARC_TC_L2_MISSES,
        ARC_TC_CRTIME,
        ARC_TC_SNAPTIME
#define	ARC_TC_IDX	ARC_TC_INST
#define	ARC_TC_MIN_COL	ARC_TC_INST
#define	ARC_TC_MAX_COL	ARC_TC_SNAPTIME
#define	ARC_TC_NUM_MIN	ARC_TC_META_USED
#define	ARC_TC_NUM_MAX	ARC_TC_L2_MISSES
#define	ARC_TC_UI32_MIN	ARC_TC_INST
#define	ARC_TC_UI32_MAX	ARC_TC_L2_SIZE_HIGH
#define	ARC_TC_C64_MIN	ARC_TC_HITS
#define	ARC_TC_C64_MAX	ARC_TC_L2_MISSES
#define	ARC_TC_TS_MIN	ARC_TC_CRTIME
#define	ARC_TC_TS_MAX	ARC_TC_SNAPTIME
} arc_table_col_t;

Netsnmp_First_Data_Point	arcstat_get_first_data_point;
Netsnmp_Next_Data_Point		arcstat_get_next_data_point;

extern int arcstat_read(arc_table_col_t, uint64_t *, hrtime_t *);
extern void arcstat_init();
extern void arcstat_destroy();
extern void arcstat_release();

#ifdef __cplusplus
}
#endif

#endif /* _ARCSTAT_ACCESS_H */
