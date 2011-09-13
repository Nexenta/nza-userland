/*
 * Subversion will populate the user's ~/.subversion/ directory with
 * default configuration files if the directory does not exist.  Some
 * of these same files are useful to system administrators who want to
 * put files in /etc/subversion/ to control site-wide configuration.
 * This program creates a default set of subversion config files in
 * the current directory.
 */ 

#include <apr.h>
#include <apr_general.h>
#include <apr_pools.h>
#include <apr_file_io.h>
#include <apr_file_info.h>
#include <svn_config.h>
#include <stdio.h>

#define ROOT_DIR "svn-defaults"

int
main(int argc, char *argv[])
{
  char *root;
  apr_pool_t *pool;
  apr_file_t *fptr;
  apr_finfo_t finfo;
  
  apr_initialize();
  apr_pool_create(&pool, NULL);
 
  apr_file_open_stderr(&fptr, pool);

  if (argc != 1)
    {
      apr_file_printf(fptr, "Usage: %s\n", argv[0]);
      apr_file_printf(fptr, "Create a set of default config files"
              "in $PWD/" ROOT_DIR "\n");
      exit(0);
    }
  
  root = apr_psprintf(pool, "%s/%s", getenv("PWD"), ROOT_DIR);

  if (!root)
    {
      apr_file_printf(fptr, "apr_psprintf failed\n");
      exit(1);
    }

  if (APR_SUCCESS == apr_stat(&finfo, root, 0, pool))
    {
      apr_file_printf(fptr, "%s exists\n", root);
      exit(1);
    }

  svn_config_ensure(root, pool);
  
  apr_terminate();
  
  return 0;
}
