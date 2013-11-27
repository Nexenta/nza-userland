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

#ifndef _ZPROP_ACCESS_H
#define	_ZPROP_ACCESS_H

#include <stdio.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum zpool_table_col {
	ZPOOL_TC_NAME = 1,
	ZPOOL_TC_GUID,
	ZPOOL_TC_HEALTH,
	ZPOOL_TC_FAILMODE,
	ZPOOL_TC_CAPACITY,
	ZPOOL_TC_SIZE_HIGH,
	ZPOOL_TC_SIZE_LOW,
	ZPOOL_TC_ALLOC_HIGH,
	ZPOOL_TC_ALLOC_LOW,
	ZPOOL_TC_FREE_HIGH,
	ZPOOL_TC_FREE_LOW,
	ZPOOL_TC_FREEING_HIGH,
	ZPOOL_TC_FREEING_LOW,
	ZPOOL_TC_EXPANDSIZE_HIGH,
	ZPOOL_TC_EXPANDSIZE_LOW,
	ZPOOL_TC_DEDUPRATIO,
	ZPOOL_TC_AUTOEXPAND
#define	ZPOOL_TC_STR_MIN	ZPOOL_TC_NAME
#define	ZPOOL_TC_STR_MAX	ZPOOL_TC_GUID
#define	ZPOOL_TC_ENUM_MIN	ZPOOL_TC_HEALTH
#define	ZPOOL_TC_ENUM_MAX	ZPOOL_TC_FAILMODE
#define	ZPOOL_TC_UI32_MIN	ZPOOL_TC_CAPACITY
#define	ZPOOL_TC_UI32_MAX	ZPOOL_TC_EXPANDSIZE_LOW
#define ZPOOL_TC_INT_MIN	ZPOOL_TC_DEDUPRATIO
#define ZPOOL_TC_INT_MAX	ZPOOL_TC_AUTOEXPAND
#define	ZPOOL_TC_MIN_COL	ZPOOL_TC_NAME
#define	ZPOOL_TC_MAX_COL	ZPOOL_TC_AUTOEXPAND
} zpool_table_col_t;

/*
 * Failuremode is ugly. See usr/src/common/zfs/zpool_prop.c and the dependency
 * it has on sys/zio.h, which is not a public header, for ZIO_FAILURE_MODE_*.
 * We do something ugly here, which is keeping our private copy of that
 * enumeration, as dragging a dependency on zio.h into userland isn't on the
 * cards.
 */
typedef enum zpool_failmode_val {
	ZPOOL_FAILMODE_WAIT = 1,
	ZPOOL_FAILMODE_CONTINUE,
	ZPOOL_FAILMODE_PANIC
} zpool_failmode_val_t;

#ifndef _TESTSUITE
#define	MY_ALLOC(this)	(malloc(sizeof(*this)))
#define	MY_FREE(this)	(free(this))
#define	MY_LOG(...)	(void) snmp_log(__VA_ARGS__)
#else
#define	MY_ALLOC(this)	(SNMP_MALLOC_TYPEDEF(typeof(*this)))
#define	MY_FREE(this)	(SNMP_FREE(this))
#ifndef _LOG_ERROR
#define	_LOG_ERROR	0
#endif
#ifndef LOG_ERR
#define	LOG_ERR		NULL
#endif /* LOG_ERR */
#ifndef MODULENAME
#define MODULENAME	"zpool"
#endif /* MODULENAME */
/* We don't care about log type, which is first param */
#define	MY_LOG(x, ....)						\
	do { if (_LOG_ERROR) fprintf(stderr, __VA_ARGS__); } while (0)
#endif /* _TESTSUITE */

Netsnmp_First_Data_Point	zprop_pool_get_first_data_point;
Netsnmp_Next_Data_Point		zprop_pool_get_next_data_point;

extern int zprop_pool_get(void *, zpool_table_col_t, uint64_t *, char **);
extern void zprop_init();
extern void zprop_destroy();
extern void zprop_release();

#ifdef __cplusplus
}
#endif

#endif /* _ZPROP_ACCESS_H */
