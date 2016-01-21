CREATE OR REPLACE PACKAGE BODY owa_cache
AS

  --
  -- Private types and global variables
  --
  v_nstatusidx  NUMBER := 1;       -- the htbuf line index for status header
  v_netagidx    NUMBER := 2;       -- the htbuf line index for etag header
  v_nexpiresidx NUMBER := 2;       -- the htbuf line index for expires header
  v_nlevelidx   NUMBER := 3;       -- the htbuf line index for level header
  v_nendlineidx NUMBER := 4;       -- the htbuf line index for end line
  --
  -- Constants
  --
  NL_CHAR constant VARCHAR(1) := '
';
  expires_header constant VARCHAR2(18) := 'X-ORACLE-EXPIRES: ';
  etag_header  constant VARCHAR2(6) := 'ETag: ';
  level_header constant VARCHAR2(15) := 'Cache-Control: ';
  ignore_header constant VARCHAR2(23) := 'X-ORACLE-IGNORE: IGNORE';
  read_header constant VARCHAR2(20) := 'X-ORACLE-CACHE: READ';
  write_header constant VARCHAR2(21) := 'X-ORACLE-CACHE: WRITE';

  --
  -- PROCEDURE:
  --   init
  -- DESCRIPTION:
  --   Reserve header spaces
  -- PARAMS:
  --   p_htbuf    IN/OUT: the buffer to reserve the headers in
  --   p_rows_in  IN/OUT: the current row number in that buffer
  -- NOTE:
  --   Should only be called before any data is written to the htbuf
  --
  PROCEDURE init(p_htbuf IN OUT NOCOPY htp.htbuf_arr, p_rows_in IN OUT number)
  IS
  BEGIN
    -- Reserve three header spaces
    p_htbuf(v_nstatusidx) := ignore_header || NL_CHAR;
    p_htbuf(v_netagidx) := ignore_header || NL_CHAR;
    p_htbuf(v_nlevelidx) := ignore_header || NL_CHAR;
    p_htbuf(v_nendlineidx) := NL_CHAR;
    p_rows_in := 3;
  END init;

  --
  -- PROCEDURE:
  --   disable
  -- DESCRIPTION:
  --   Disables the cache
  --
  PROCEDURE disable
  IS
  BEGIN
     htp.print_header(ignore_header, v_nstatusidx);
     htp.print_header(ignore_header, v_netagidx);
     htp.print_header(ignore_header, v_nlevelidx);
  END disable;


  --
  -- PROCEDURE:
  --   set_expires
  -- DESCRIPTION:
  --   Sets up the cache headers
  -- PARAMS:
  --   p_expires  IN: number of minutes this cached item is fresh
  --   p_level    IN: the caching level for it (USER or SYSTEM for now)
  -- EXCEPTIONS:
  --   VALUE_ERROR : If p_expires is negative or zero, or p_level is not
  --                 'USER' or 'SYSTEM', this exception is thrown
  --                 If p_expires is > 525600 (1 year), this exception is thrown
  --
  PROCEDURE set_expires(p_expires IN number, p_level IN varchar2)
  IS
  BEGIN
     -- Check for negative numbers or zero
     IF (p_expires <= 0) THEN
        raise VALUE_ERROR;
     END IF;

     -- Check for > 525600
     IF (p_expires > 525600) THEN
        raise VALUE_ERROR;
     END IF;

     -- Check for invalid levels
     IF (p_level IS NULL) THEN
        raise VALUE_ERROR;
     END IF;

     IF (p_level <> 'SYSTEM' AND p_level <> 'USER') THEN
        raise VALUE_ERROR;
     END IF;

     htp.print_header(write_header, v_nstatusidx);
     htp.print_header(expires_header || p_expires, v_nexpiresidx);
     htp.print_header(level_header || p_level, v_nlevelidx);
  END set_expires;


  --
  -- PROCEDURE:
  --   set_cache
  -- DESCRIPTION:
  --   Sets up the cache headers
  -- PARAMS:
  --   p_etag     IN: the ETag associated with this content
  --   p_level    IN: the caching level for it (USER or SYSTEM for now)
  -- EXCEPTIONS:
  --   VALUE_ERROR : If p_etag is greater than 55 in length or p_level is
  --                 not 'USER' or 'SYSTEM', this exception is thrown
  --
  PROCEDURE set_cache(p_etag IN varchar2, p_level IN varchar2)
  IS
  BEGIN
     -- Check for the etag length
     IF (p_etag IS NULL OR length(p_etag) > 55) THEN
        raise VALUE_ERROR;
     END IF;

     -- Check for invalid levels
     IF (p_level IS NULL) THEN
        raise VALUE_ERROR;
     END IF;

     IF (p_level <> 'SYSTEM' AND p_level <> 'USER') THEN
        raise VALUE_ERROR;
     END IF;

     htp.print_header(write_header, v_nstatusidx);
     htp.print_header(etag_header || p_etag, v_netagidx);
     htp.print_header(level_header || p_level, v_nlevelidx);
  END set_cache;


  --
  -- PROCEDURE:
  --   set_not_modified
  -- DESCRIPTION:
  --   Sets up the headers for a not modified cache hit
  -- EXCEPTIONS:
  --   VALUE_ERROR : If the ETag or Cache-Control wasn't passed in,
  --                 this exception is thrown
  --
  PROCEDURE set_not_modified
  IS
  BEGIN
     IF (get_etag IS NULL OR get_level IS NULL) THEN
        raise VALUE_ERROR;
     END IF;

     htp.print_header(read_header, v_nstatusidx);
     htp.print_header(ignore_header, v_netagidx);
     htp.print_header(ignore_header, v_nlevelidx);
  END set_not_modified;


  --
  -- FUNCTION:
  --   get_level
  -- DESCRIPTION:
  --   Returns the caching level
  -- PARAMS:
  --   none
  -- RETURN:
  --   The caching level string (USER or SYSTEM for now)
  --
  FUNCTION get_level
    RETURN VARCHAR2
  IS
  BEGIN
     RETURN (owa_util.get_cgi_env('HTTP_CACHE_CONTROL'));
  END get_level;

  --
  -- FUNCTION:
  --   get_etag
  -- DESCRIPTION:
  --   Returns the caching etag
  -- PARAMS:
  --   none
  -- RETURN:
  --   The caching etag string
  --
  FUNCTION get_etag
    RETURN VARCHAR2
  IS
  BEGIN
     RETURN (owa_util.get_cgi_env('HTTP_IF_MATCH'));
  END get_etag;
END owa_cache;
/
