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

#include <kstat.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <thread.h>
#include <synch.h>
#include <sys/time.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>
#include "arc_access.h"
#include "zfs_snmp.h"

typedef struct arcstats {
	kstat_ctl_t	*as_kc;
	kstat_t		*as_ks;
	rwlock_t	as_lock;
	hrtime_t	as_ts;
} arcstats_t;

static arcstats_t *arcstat = NULL;

/* Cache timeout in seconds converted to ns */
static hrtime_t cache_timeout = (ZPOOL_CACHE_TIMEOUT * 1E9);

/*
 * If cache is expired or not yet populated, readers will race to update the
 * cache via this function. If we find that the timestamp has increased since
 * the caller copied it out for comparison, an update already happened.
 */
static void
arcstat_update(hrtime_t *ts)
{
	kstat_ctl_t *kc = arcstat->as_kc;
	kstat_t *ks = arcstat->as_ks;

	rw_wrlock(&arcstat->as_lock);
	if (arcstat->as_ts > *ts) {
		rw_unlock(&arcstat->as_lock);
		return;
	}
	/* This shouldn't happen */
	if (kstat_read(kc, ks, NULL) == -1) {
		snmp_log(LOG_ERR, "%s: kstat_read failed in %s(): %s\n",
		    MODULE_NAME, __FUNCTION__, strerror(errno));
		goto invalid;
	}
	arcstat->as_ts = gethrtime();
invalid:
	rw_unlock(&arcstat->as_lock);

	DEBUGMSGTL((MODULE_NAME, "%s() successful.\n", __FUNCTION__));

	return;
}

static void
arcstat_check()
{
	hrtime_t now;
	hrtime_t ts;

	(void) rw_rdlock(&arcstat->as_lock);
	now = gethrtime();
	ts = arcstat->as_ts;
	if ((now - ts) > cache_timeout) {
		rw_unlock(&arcstat->as_lock);
		arcstat_update(&ts);
	}
	(void) rw_rdlock(&arcstat->as_lock);
	return;
}

void
arcstat_release()
{
	if (RW_LOCK_HELD(&arcstat->as_lock))
		rw_unlock(&arcstat->as_lock);
}

/*
 * Part of the table_iterator helper pattern (see netsnmp_table_iterator),
 * returns the first data point within the arcstat table data and establishes
 * context for subsequent operations against the table in terms of the data we
 * need to render (arcstat) and its indexes (the kstat instance ID). The API
 * gives us access to my_data_context via netsnmp_extract_iterator_context().
 * We don't really need this context information in this case, we only need to
 * set index values, as we only allow for a single conceptual row, but we set
 * things up here as though we allow for and need context, leaving the laming
 * for the get_next function.
 */
/* ARGSUSED3 */
netsnmp_variable_list *
arcstat_get_first_data_point(void **my_loop_context, void **my_data_context,
    netsnmp_variable_list *put_index_data, netsnmp_iterator_info *mydata)
{
	kstat_t *ks = NULL;
	netsnmp_variable_list *vptr;

	/* This should never happen. */
	if (arcstat == NULL) {
		snmp_log(LOG_ERR, "%s: arcstat is NULL in %s().\n", MODULE_NAME,
		    __FUNCTION__);
		return (NULL);
	}
	arcstat_check();
	ks = arcstat->as_ks;
	/* This should never happen */
	if (ks == NULL) {
		snmp_log(LOG_ERR, "%s: arcstat invalid in %s().\n", MODULE_NAME,
		    __FUNCTION__);
		return (NULL);
	}

	*my_loop_context = arcstat;
	*my_data_context = arcstat;

	vptr = put_index_data;
	snmp_set_var_value(vptr, (uchar_t *)&ks->ks_instance,
	    sizeof (ks->ks_instance));
	return (put_index_data);
}

/*
 * There never is a next data point, since instance 0 is the only one for us,
 * but it's easy enough to support this later by making arcstats_t into a
 * linked list.
 */
/* ARGSUSED */
netsnmp_variable_list *
arcstat_get_next_data_point(void **my_loop_context, void **my_data_context,
    netsnmp_variable_list *put_index_data, netsnmp_iterator_info *mydata)
{
	return (NULL);
}

void
arcstat_destroy()
{
	kstat_ctl_t *kc;

	if (arcstat == NULL)
		return;

	kc = arcstat->as_kc;
	(void) kstat_close(kc);
	(void) rwlock_destroy(&arcstat->as_lock);
	SNMP_FREE(arcstat);
}

/*
 * Internal helper function to initialise the arcstat cache.
 */
void
arcstat_init()
{
	kstat_ctl_t *kc;
	kstat_t *ks;

	if (arcstat != NULL) {
		snmp_log(LOG_ERR, "%s: arcstat already exists in %s()\n",
		    MODULE_NAME, __FUNCTION__);
		return;
	}

	if ((arcstat = SNMP_MALLOC_TYPEDEF(arcstats_t)) == NULL) {
		snmp_log(LOG_ERR, "%s: arcstat alloc failed in %s(): %s\n",
		    MODULE_NAME, __FUNCTION__, strerror(errno));
		return;
	}
	rwlock_init(&arcstat->as_lock, USYNC_THREAD, NULL);
	arcstat->as_ts = 0;
	if ((kc = kstat_open()) == NULL) {
		snmp_log(LOG_ERR, "%s: kstat_open failed in %s(): %s\n",
		    MODULE_NAME, __FUNCTION__, strerror(errno));
		goto fail;
	}
	if ((ks = kstat_lookup(kc, "zfs", 0, "arcstats")) == NULL) {
		snmp_log(LOG_ERR, "%s: kstat_lookup failed in %s(): %s\n",
		    MODULE_NAME, __FUNCTION__, strerror(errno));
		goto fail2;
	}
	arcstat->as_ks = ks;
	arcstat->as_kc = kc;

	DEBUGMSGTL((MODULE_NAME, "%s() completed successfully\n",
		__FUNCTION__));

	return;

fail2:
	(void) kstat_close(kc);
fail:
	(void) rwlock_destroy(&arcstat->as_lock);
	SNMP_FREE(arcstat);
	/* XXX time to abort()? */
	return;
}

/*
 * Internal helper function to retrieve arcstat kstat values. The arcstats
 * kstat is a kstat with a series of named kstats. We take column identifiers
 * and convert those to the names to read out. All the values within the ARC
 * stats proper are uint64s, but we also have to handle the timestamp values
 * for crtime and snaptime. Where possible, normalise sizes from bytes to KB.
 * We have to deal directly with special-casing for L2ARC space representation,
 * as even with KB conversion, we have to user higher and lower order bits to
 * pass a non-counter value that can't be represented with 32 bits.
 */
int
arcstat_read(arc_table_col_t col, uint64_t *val, hrtime_t *ts)
{
	kstat_t		*ks = arcstat->as_ks;
	kstat_named_t	*knp;
	char 		*name;
	boolean_t	kbconv = B_FALSE;
	boolean_t	dual = B_FALSE;
	boolean_t	low = B_FALSE;
	uint64_t	v;

	if (ks == NULL) {
		snmp_log(LOG_ERR, "%s: %s() against a NULL kstat pointer\n",
		    MODULE_NAME, __FUNCTION__);
		return (EINVAL);
	}

	DEBUGMSGTL((MODULE_NAME, "%s() for column %d\n", __FUNCTION__, col));

	switch (col) {
	case ARC_TC_INST:
		v = ks->ks_instance;
		*val = v;
		return (0);
	case ARC_TC_META_USED:
		kbconv = B_TRUE;
		name = "arc_meta_used";
		break;
	case ARC_TC_C:
		kbconv = B_TRUE;
		name = "c";
		break;
	case ARC_TC_P:
		kbconv = B_TRUE;
		name = "p";
		break;
	case ARC_TC_SIZE:
		kbconv = B_TRUE;
		name = "size";
		break;
	case ARC_TC_L2_SIZE_LOW:
	case ARC_TC_L2_SIZE_HIGH:
		dual = B_TRUE;
		kbconv = B_TRUE;
		name = "l2_size";
		if (col == ARC_TC_L2_SIZE_LOW)
			low = B_TRUE;
		break;
	case ARC_TC_HITS:
		name = "hits";
		break;
	case ARC_TC_MISSES:
		name = "misses";
		break;
	case ARC_TC_DEMAND_DATA_HITS:
		name = "demand_data_hits";
		break;
	case ARC_TC_DEMAND_DATA_MISSES:
		name = "demand_data_misses";
		break;
	case ARC_TC_DEMAND_METADATA_HITS:
		name = "demand_metadata_hits";
		break;
	case ARC_TC_DEMAND_METADATA_MISSES:
		name = "demand_metadata_misses";
		break;
	case ARC_TC_PREFETCH_DATA_HITS:
		name = "prefetch_data_hits";
		break;
	case ARC_TC_PREFETCH_DATA_MISSES:
		name = "prefetch_data_misses";
		break;
	case ARC_TC_PREFETCH_METADATA_HITS:
		name = "prefetch_metadata_hits";
		break;
	case ARC_TC_PREFETCH_METADATA_MISSES:
		name = "prefetch_metadata_misses";
		break;
	case ARC_TC_MFU_GHOST_HITS:
		name = "mfu_ghost_hits";
		break;
	case ARC_TC_MFU_HITS:
		name = "mfu_hits";
		break;
	case ARC_TC_MRU_GHOST_HITS:
		name = "mru_ghost_hits";
		break;
	case ARC_TC_MRU_HITS:
		name = "mru_hits";
		break;
	case ARC_TC_L2_HITS:
		name = "l2_hits";
		break;
	case ARC_TC_L2_MISSES:
		name = "l2_misses";
		break;
	case ARC_TC_CRTIME:
		*ts = ks->ks_crtime;
		return (0);
	case ARC_TC_SNAPTIME:
		*ts = ks->ks_snaptime;
		return (0);
	default:
		snmp_log(LOG_ERR, "%s: %s() invalid column (%d)\n",
		    MODULE_NAME, __FUNCTION__, col);
		return (EINVAL);
	}

	if ((knp = kstat_data_lookup(ks, (char *)name)) == NULL) {
		snmp_log(LOG_ERR, "%s: %s() arcstat %s lookup error in: %s",
		    MODULE_NAME, __FUNCTION__, name, strerror(errno));
		return (errno);
	}
	/* All values should be uint64, so this shouldn't happen at runtime */
	if (knp->data_type != KSTAT_DATA_UINT64) {
		snmp_log(LOG_ERR, "%s: %s arcstat %s kstat not a uint64 (%s)\n",
		    MODULE_NAME, __FUNCTION__, name, knp->data_type);
		return (EINVAL);
	}

	v = (kbconv) ? knp->value.ui64 / 1024 : knp->value.ui64;
	if (dual) {
		if (low) {
			v = v & 0xffffffff;
		} else {
			v = v >> 32;
		}
	}
	*val = v;

	DEBUGMSGTL((MODULE_NAME, "%s() value %llu for column %d\n",
		__FUNCTION__, *val, col));

	return (0);
}
