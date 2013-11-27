/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */

/*
 * Copyright 2013 Nexenta Systems, Inc.  All rights reserved.
 */

#ifndef	_LIBZFS_CORE_PRIV_H
#define	_LIBZFS_CORE_PRIV_H

#include <libnvpair.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/fs/zfs.h>

#ifdef	__cplusplus
extern "C" {
#endif

int lzc_pool_stats(const char *, nvlist_t **);
int lzc_pool_configs(uint64_t *, nvlist_t **);
int lzc_pool_get_props(const char *, nvlist_t **);

int lzc_dataset_list_next(const char *, uint64_t *, char **, nvlist_t **,
    nvlist_t **);
int lzc_snapshot_list_next(const char *, uint64_t *, char **, nvlist_t **,
    nvlist_t **);
int lzc_objset_stats(const char *, dmu_objset_type_t *, nvlist_t **, nvlist_t **);


#ifdef	__cplusplus
}
#endif

#endif	/* _LIBZFS_CORE_PRIV_H */
