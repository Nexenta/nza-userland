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

#include <sys/time.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>
#include "zfs_snmp.h"
#include "arc_access.h"
#include "zprop_access.h"

/*
 * This table handler is a bit different than others, as we have a number of
 * related records that we've chosen to represent as table with a single
 * conceptual record. Thus we have a reduced reliance on context and only need
 * to keep track of where we are in terms of columns.
 */
/* ARGSUSED */
static int
arcTable_handler(netsnmp_mib_handler *handler,
    netsnmp_handler_registration *reginfo, netsnmp_agent_request_info *reqinfo,
    netsnmp_request_info *requests)
{
	int i = 0;
	int err;
	netsnmp_request_info *request;
	netsnmp_table_request_info *table_info;
	netsnmp_variable_list *var;
	void *data_context = NULL;

	for (request = requests; request; request = request->next) {
		var = request->requestvb;
		if (request->processed != 0)
			continue;
		if (reqinfo->mode != MODE_GET) {
			(void) snmp_log(LOG_ERR,
			    "%s: problem encountered in %s: unsupported mode\n",
			    MODULE_NAME, ARCTABLE_NAME);
			continue;
		}

		DEBUGMSGTL((MODULE_NAME, "%s request item no %d\n",
			ARCTABLE_NAME, ++i));

		data_context = netsnmp_extract_iterator_context(request);
		if (data_context == NULL) {
			(void) netsnmp_set_request_error(reqinfo, request,
			    SNMP_NOSUCHINSTANCE);
			continue;
		}

		if ((table_info = netsnmp_extract_table_info(request)) == NULL)
			continue;

		DEBUGMSGTL((MODULE_NAME, "%s table column = %d\n",
			ARCTABLE_NAME, table_info->colnum));
		/*
		 * We handle the index, although that should be taken care of
		 * in the get_first/get_next context handlers.
		 */
		if ((table_info->colnum >= ARC_TC_MIN_COL) &&
		    (table_info->colnum <= ARC_TC_MAX_COL)) {
			uint64_t val;
			hrtime_t ts;

			err = arcstat_read(table_info->colnum, &val, &ts);
			if (err != 0) {
				(void) snmp_log(LOG_ERR, 
				    "%s: %s() error retrieving values\n",
				    MODULE_NAME, __FUNCTION__);
				(void) netsnmp_set_request_error(reqinfo,
				    request, SNMP_ERR_GENERR);
			}

			if (table_info->colnum >= ARC_TC_C64_MIN &&
			    table_info->colnum <= ARC_TC_C64_MAX) {
				struct counter64 c64;
				/*
				 * Net-SNMP doesn't provide 64-bit support via
				 * native 64-bit representations, so we have to
				 * convert to the API's split 32-bit structure.
				 */
				c64.high = val >> 32;
				c64.low = val & 0xffffffff;
				(void) snmp_set_var_typed_value(var,
				    ASN_COUNTER64, (uchar_t *)&c64,
				    sizeof (c64));
			} else if (table_info->colnum >= ARC_TC_UI32_MIN &&
			    table_info->colnum <= ARC_TC_UI32_MAX) {
				/*
				 * Should handle truncation for us and log
				 * overflow without failure we need to handle
				 */
				(void) snmp_set_var_typed_value(var,
				    ASN_UNSIGNED, (uchar_t *)&val,
				    sizeof (val));
			} else if (table_info->colnum >= ARC_TC_TS_MIN &&
			    table_info->colnum <= ARC_TC_TS_MAX) {
				uint64_t tval = ts/10000000;
				/*
				 * SNMP timeticks have resolution to hundreths
				 * of sec, may display funny with tools like
				 * snmpwalk, which assume ticks since epoch.
				 * Similar story for the converstion function
				 * handling 32-bit conversion/truncation as for
				 * the UI32 case.
				 */
				(void) snmp_set_var_typed_value(var,
				    ASN_TIMETICKS, (uchar_t *)&tval,
				    sizeof (tval));
			} else { /* should not happen */
				(void) snmp_log(LOG_ERR,
				    "%s: problem encountered in %s handler: "
				    "unknown column type (%d)\n", MODULE_NAME,
				    ARCTABLE_NAME, table_info->colnum);
			}
		} else { /* should not happen */
			(void) snmp_log(LOG_ERR, "%s: problem encountered in "
			    "%s handler: unknown column (%d)\n", MODULE_NAME,
			    ARCTABLE_NAME, table_info->colnum);
			(void) netsnmp_set_request_error(reqinfo, request,
			    SNMP_ERR_GENERR);
		}
		/*
		 * XXX We release the lock around the cache between requests,
		 * so it's possible for a client to read from two different
		 * reads of the kstats. This is tolerable given that we're
		 * rolling our own caching to compensate for what doesn't work
		 * in Net-SNMP.
		 */
		arcstat_release();
	}

	return (SNMP_ERR_NOERROR);
}

/*
 * Register our MIB's table with Net-SNMP, define table structure, and set up
 * handler. We set up handler for the separate count oid at the same time, as
 * it's intimately linked to the table. This function is called from the module
 * load function, which can't return any errors, so we return void.
 */
static void
initialize_table_arcTable(void)
{
	static oid arcTable_oid[] = { ARCTABLE_OID };
	netsnmp_table_registration_info *table_info;
	netsnmp_handler_registration *arc_handler;
	netsnmp_iterator_info *iinfo;
	int err;

	table_info = SNMP_MALLOC_TYPEDEF(netsnmp_table_registration_info);
	iinfo = SNMP_MALLOC_TYPEDEF(netsnmp_iterator_info);

	arc_handler = netsnmp_create_handler_registration(ARCTABLE_NAME,
	    arcTable_handler, arcTable_oid, OID_LENGTH(arcTable_oid),
	    HANDLER_CAN_RONLY);

	if (!arc_handler || !table_info || !iinfo) {
		(void) snmp_log(LOG_ERR, "%s: malloc failed in %s", 
		    MODULE_NAME, __FUNCTION__);
		goto failure;
	}

	/* Although the table has a single row, index just in case */
	netsnmp_table_helper_add_indexes(table_info, ASN_UNSIGNED, 0);
	/* Index for this table is accessible as read-only */
	table_info->min_column = ARC_TC_MIN_COL;
	table_info->max_column = ARC_TC_MAX_COL;
	DEBUGMSGTL((MODULE_NAME, "%s: first column = %d and last column = "
		"%d\n", ARCTABLE_NAME, table_info->min_column,
		table_info->max_column));

	iinfo->get_first_data_point = arcstat_get_first_data_point;
	iinfo->get_next_data_point = arcstat_get_next_data_point;

	iinfo->table_reginfo = table_info;
	err = netsnmp_register_table_iterator(arc_handler, iinfo);
	if (err != MIB_REGISTERED_OK) {
		(void) snmp_log(LOG_ERR, "%s: table iterator registration "
		    "failed from %s() (%d)", MODULE_NAME, __FUNCTION__, err);
		goto failure;
	}
	return;

failure:
	if (iinfo)
		netsnmp_iterator_delete_table(iinfo);
	if (arc_handler)
		netsnmp_handler_registration_free(arc_handler);
	if (table_info)
		SNMP_FREE(table_info);
	return;
}

static void
init_arc()
{
	arcstat_init();
	initialize_table_arcTable();
}

/* XXX Net-SNMP unclear about freeing handlers on unregister_mib() */
static void
deinit_arc()
{
	static oid arcTable_oid[] = { ARCTABLE_OID };
	int err;

	err = unregister_mib(arcTable_oid, OID_LENGTH(arcTable_oid));
	if (err != MIB_UNREGISTERED_OK)
		(void) snmp_log(LOG_ERR, "%s: table mib unregister failed for "
		    "table %s from %s() (%d)", MODULE_NAME, ARCTABLE_NAME,
		    __FUNCTION__, err);
	arcstat_destroy();
	DEBUGMSGTL((MODULE_NAME, "Deinitialized %s\n", ARCTABLE_NAME));
}

/* ARGSUSED */
static int
zpoolTable_handler(netsnmp_mib_handler *handler,
    netsnmp_handler_registration *reginfo, netsnmp_agent_request_info *reqinfo,
    netsnmp_request_info *requests)
{
	int i = 0;
	int err;
	netsnmp_request_info *request;
	netsnmp_table_request_info *table_info;
	netsnmp_variable_list *var;
	void *ctx = NULL;

	for (request = requests; request; request = request->next) {
		var = request->requestvb;
		if (request->processed != 0)
			continue;
		if (reqinfo->mode != MODE_GET) {
			(void) snmp_log(LOG_ERR, "%s: problem encountered in "
			    "%s: unsupported mode\n", MODULE_NAME,
			    ZPOOLTABLE_NAME);
			continue;
		}

		DEBUGMSGTL((MODULE_NAME, "%s request item no %d\n",
			ZPOOLTABLE_NAME, ++i));

		ctx = netsnmp_extract_iterator_context(request);
		if (ctx == NULL) {
			(void) netsnmp_set_request_error(reqinfo, request,
			    SNMP_NOSUCHINSTANCE);
			continue;
		}

		if ((table_info = netsnmp_extract_table_info(request)) == NULL)
			continue;

		DEBUGMSGTL((MODULE_NAME, "%s table column = %d\n",
			ZPOOLTABLE_NAME, table_info->colnum));

		if ((table_info->colnum >= ZPOOL_TC_MIN_COL) &&
		    (table_info->colnum <= ZPOOL_TC_MAX_COL)) {
			uint64_t val;
			char *str;

			err =
			    zprop_pool_get(ctx, table_info->colnum, &val, &str);
			if (err != 0) {
				(void) snmp_log(LOG_ERR,
				    "%s: %s() error retrieving values\n",
				    MODULE_NAME, __FUNCTION__);
				(void) netsnmp_set_request_error(reqinfo,
				    request, SNMP_ERR_GENERR);
			}

			if (table_info->colnum >= ZPOOL_TC_STR_MIN &&
			    table_info->colnum <= ZPOOL_TC_STR_MAX) {
				DEBUGMSGTL((MODULE_NAME, "%s() col %d = %s\n",
					ZPOOLTABLE_NAME, table_info->colnum,
					(str != NULL ? str : "NULL")));
				/*
				 * Net-SNMP doesn't need NULL terminators
				 * included in string length, but we have to
				 * perform error checking to make sure it can
				 * allocate buffers for ASN.1 representation.
				 */
				err = snmp_set_var_typed_value(var,
				    ASN_OCTET_STR, (uchar_t *)str,
				    strlen(str));
				if (err != 0) {
					(void) snmp_log(LOG_ERR,
					    "%s: %s() error rendering string "
					    "col %d (%s)\n", MODULE_NAME,
					    __FUNCTION__, table_info->colnum,
					    (str != NULL ? str : "NULL"));
					(void) netsnmp_set_request_error(
					    reqinfo, request, SNMP_ERR_GENERR);
				}
			} else if (table_info->colnum >= ZPOOL_TC_UI32_MIN &&
			    table_info->colnum <= ZPOOL_TC_UI32_MAX) {
				/*
				 * These are effectively gauge representations,
				 * so we use unsigned 32-bit representation.
				 * Some of these values are 64-bit values that
				 * don't have a 64-bit gauge in the SMIv2 base
				 * types, so we break them down in to higher
				 * and lower order bits.
				 */
				(void) snmp_set_var_typed_value(var,
				    ASN_UNSIGNED, (uchar_t *)&val,
				    sizeof (val));
			} else if (table_info->colnum >= ZPOOL_TC_ENUM_MIN &&
			    table_info->colnum <= ZPOOL_TC_ENUM_MAX) {
				/*
				 * See comments to zpool_prop_init() in
				 * usr/src/common/zfs/zpool_prop.c--property
				 * types include indexes, which have integer
				 * representation within the kernel but have
				 * string representations mediated by enums
				 * for userland. We use textual conventions
				 * mapped to integers as the SNMP equivalent.
				 * Fortunately for us the C enums for all of
				 * these start at 1, which conforms to SMIv2's
				 * recommendation for textual conventions
				 * (RFC2578 7.1.1), which passes "smilint -l3"
				 */
				(void) snmp_set_var_typed_value(var,
				    ASN_INTEGER, (uchar_t *)&val,
				    sizeof (val));
			} else if (table_info->colnum >= ZPOOL_TC_INT_MIN &&
			    table_info->colnum <= ZPOOL_TC_INT_MAX) {
				/*
				 * These values are integers but use different
				 * textual conventions: either TruthValue
				 * (RFC2579 2) or DISPLAY-HINT (3.1), where
				 * the kernel passes values as whole numbers
				 * that should be represented externally with
				 * decimals.
				 */
				(void) snmp_set_var_typed_value(var,
				    ASN_INTEGER, (uchar_t *)&val,
				    sizeof (val));
			} else { /* should not happen */
				(void) snmp_log(LOG_ERR,
				    "%s: problem encountered in %s handler: "
				    "unknown column type (%d)\n", MODULE_NAME,
				    ZPOOLTABLE_NAME, table_info->colnum);
			}
		} else { /* should not happen */
			(void) snmp_log(LOG_ERR, "%s: problem encountered in "
			    "%s handler: unknown column (%d)\n", MODULE_NAME,
			    ZPOOLTABLE_NAME, table_info->colnum);
			(void) netsnmp_set_request_error(reqinfo, request,
			    SNMP_ERR_GENERR);
		}
	}
	zprop_release();

	return (SNMP_ERR_NOERROR);
}

/*
 * Register our MIB's table with Net-SNMP, define table structure, and set up
 * handler. We set up handler for the separate count oid at the same time, as
 * it's intimately linked to the table. This function is called from the module
 * load function, which can't return any errors, so we return void.
 */
static void
initialize_table_zpoolTable(void)
{
	static oid zpoolTable_oid[] = { ZPOOLTABLE_OID };
	netsnmp_table_registration_info *table_info;
	netsnmp_handler_registration *zpool_handler;
	netsnmp_iterator_info *iinfo;
	int err;

	table_info = SNMP_MALLOC_TYPEDEF(netsnmp_table_registration_info);
	iinfo = SNMP_MALLOC_TYPEDEF(netsnmp_iterator_info);

	zpool_handler = netsnmp_create_handler_registration(ZPOOLTABLE_NAME,
	    zpoolTable_handler, zpoolTable_oid, OID_LENGTH(zpoolTable_oid),
	    HANDLER_CAN_RONLY);

	if (!zpool_handler || !table_info || !iinfo) {
		(void) snmp_log(LOG_ERR, "%s: malloc failed in %s\n",
		    MODULE_NAME, __FUNCTION__);
		goto failure;
	}

	/* We index on both GUID and name */
	netsnmp_table_helper_add_indexes(table_info, ASN_OCTET_STR,
	    ASN_OCTET_STR, 0);
	/* Index for this table is accessible as read-only */
	table_info->min_column = ZPOOL_TC_MIN_COL;
	table_info->max_column = ZPOOL_TC_MAX_COL;
	DEBUGMSGTL((MODULE_NAME, "%s: first column = %d and last column = "
		"%d\n", ZPOOLTABLE_NAME, table_info->min_column,
		table_info->max_column));

	iinfo->get_first_data_point = zprop_pool_get_first_data_point;
	iinfo->get_next_data_point = zprop_pool_get_next_data_point;

	iinfo->table_reginfo = table_info;
	err = netsnmp_register_table_iterator(zpool_handler, iinfo);
	if (err != MIB_REGISTERED_OK) {
		(void) snmp_log(LOG_ERR,
		    "%s: table iterator registration failed from %s() (%d)\n",
		    MODULE_NAME, __FUNCTION__, err);
		goto failure;
	}
	return;

failure:
	if (iinfo)
		netsnmp_iterator_delete_table(iinfo);
	if (zpool_handler)
		netsnmp_handler_registration_free(zpool_handler);
	if (table_info)
		SNMP_FREE(table_info);
	return;
}

static void
init_zprop(void)
{
	zprop_init();
	initialize_table_zpoolTable();
}

/* XXX Net-SNMP unclear about freeing handlers on unregister_mib() */
void
deinit_zprop(void)
{
	static oid zpoolTable_oid[] = { ZPOOLTABLE_OID };
	int err;

	err = unregister_mib(zpoolTable_oid, OID_LENGTH(zpoolTable_oid));
	if (err != MIB_UNREGISTERED_OK)
		(void) snmp_log(LOG_ERR,
		    "%s: table mib unregister failed for table %s from %s() "
		    "(%d)", MODULE_NAME, ZPOOLTABLE_NAME, __FUNCTION__, err);
	zprop_destroy();
	DEBUGMSGTL((MODULE_NAME, "Deinitialized %s\n", ZPOOLTABLE_NAME));
}

/* Module initialisation function defined by SNMP API. */
void
init_zfs(void)
{
	DEBUGMSGTL((MODULE_NAME, "Initializing zpool extension\n"));
	init_arc();
	init_zprop();
}

void
deinit_zfs(void)
{
	DEBUGMSGTL((MODULE_NAME, "Terminating zpool extension\n"));
	deinit_arc();
	deinit_zprop();
}
