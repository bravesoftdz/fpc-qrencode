unit getopt;

interface

uses
  Windows;

var
{* For communication from `getopt' to the caller.
   When `getopt' finds an option that takes an argument,
   the argument value is returned here.
   Also, when `ordering' is RETURN_IN_ORDER,
   each non-option ARGV-element is returned here.  *}

  optarg: PAnsiChar = nil;

{* Index in ARGV of the next element to be scanned.
   This is used for communication to and from the caller
   and for communication between successive calls to `getopt'.

   On entry to `getopt', zero means this is the first call; initialize.

   When `getopt' returns EOF, this is the index of the first of the
   non-option elements that the caller should itself scan.

   Otherwise, `optind' communicates from one call to the next
   how much of ARGV has been scanned so far.  *}

  optind: Integer = 0;

{* Callers store zero here to inhibit the error message `getopt' prints
   for unrecognized options.  *}

  opterr: Integer = 1;

{* Set to an option character which was unrecognized.  *}

  optopt: Integer = Ord('?');

{* Describe the long-named options requested by the application.
   The LONG_OPTIONS argument to getopt_long or getopt_long_only is a vector
   of `struct option' terminated by an element containing a name which is
   zero.

   The field `has_arg' is:
   no_argument		(or 0) if the option does not take an argument,
   required_argument	(or 1) if the option requires an argument,
   optional_argument 	(or 2) if the option takes an optional argument.

   If the field `flag' is not NULL, it points to a variable that is set
   to the value given in the field `val' when the option is found, but
   left unchanged if the option is not found.

   To have a long-named option do something other than set an `int' to
   a compiled-in constant, such as set a value from `optarg', set the
   option's `flag' field to zero and its `val' field to a nonzero
   value (the equivalent single-letter option character, if there is
   one).  For long options that have a zero `flag' field, `getopt'
   returns the contents of the `val' field.  *}


const
{* Names for the values of the `has_arg' field of `struct option'.  *}
  no_argument	=	0;
  required_argument =	1;
  optional_argument	= 2;

type
  option = record
    name: PAnsiChar;
    {* has_arg can't be an enum because some compilers complain about
       type mismatches in all the code that assumes it is an int.  *}
    has_arg: Integer;
    flag: PInteger;
    val: Integer;
  end;

//#if defined (__STDC__) && __STDC__
//#ifdef __GNU_LIBRARY__
{* Many other libraries have conflicting prototypes for getopt, with
   differences in the consts, in stdlib.h.  To avoid compilation
   errors, only prototype getopt for the GNU C library.  *}
//extern int getopt (int argc, char *const *argv, const char *shortopts);
//#else /* not __GNU_LIBRARY__ */
//extern int getopt ();
//#endif /* __GNU_LIBRARY__ */
function getopt_long(argc: Integer; const argv: PAnsiChar;
  const shortopts: PAnsiChar; const longopts: option;
  longind: PInteger): Integer;
//extern int getopt_long (int argc, char *const *argv, const char *shortopts,
//		        const struct option *longopts, int *longind);
function getopt_long_only(argc: Integer; const argv: PAnsiChar;
  const shortopts: PAnsiChar; const longopt: option;
  longind: PInteger): Integer;
//extern int getopt_long_only (int argc, char *const *argv,
//			     const char *shortopts,
//		             const struct option *longopts, int *longind);

{* Internal only.  Users should not call this directly.  *}
//function _getopt_internal(argc: Integer; const argv: PAnsiChar;
//  const shortopts: PAnsiChar; const longopts: option;
//  longind: PInteger; long_only: Integer): Integer;
//extern int _getopt_internal (int argc, char *const *argv,
//			     const char *shortopts,
//		             const struct option *longopts, int *longind,
//			     int long_only);
//#else {* not __STDC__ *}
//extern int getopt ();
//extern int getopt_long ();
//extern int getopt_long_only ();
//
//extern int _getopt_internal ();  

implementation

{* Describe how to deal with options that follow non-option ARGV-elements.

   If the caller did not specify anything,
   the default is REQUIRE_ORDER if the environment variable
   POSIXLY_CORRECT is defined, PERMUTE otherwise.

   REQUIRE_ORDER means don't recognize them as options;
   stop option processing when the first non-option is seen.
   This is what Unix does.
   This mode of operation is selected by either setting the environment
   variable POSIXLY_CORRECT, or using `+' as the first character
   of the list of option characters.

   PERMUTE is the default.  We permute the contents of ARGV as we scan,
   so that eventually all the non-options are at the end.  This allows options
   to be given in any order, even with programs that were not written to
   expect this.

   RETURN_IN_ORDER is an option available to programs that were written
   to expect options and other ARGV-elements in any order and that care about
   the ordering of the two.  We describe each non-option ARGV-element
   as if it were the argument of an option with character code 1.
   Using `-' as the first character of the list of option characters
   selects this mode of operation.

   The special argument `--' forces an end of option-scanning regardless
   of the value of `ordering'.  In the case of RETURN_IN_ORDER, only
   `--' can cause `getopt' to return EOF with `optind' != ARGC.  *}

type
  TOrdering = (REQUIRE_ORDER, PERMUTE, RETURN_IN_ORDER);

var
  ordering: TOrdering;
{* The next char to be scanned in the option-element
   in which the last option character we returned was found.
   This allows us to pick up the scan where we left off.

   If this is zero, or a null string, it means resume the scan
   by advancing to the next ARGV-element.  *}
  nextchar: PAnsiChar = nil;

{* Value of POSIXLY_CORRECT environment variable.  *}
  posixly_correct: PAnsiChar;

{* Describe the part of ARGV that contains non-options that have
   been skipped.  `first_nonopt' is the index in ARGV of the first of them;
   `last_nonopt' is the index after the last of them.  *}
  first_nonopt: Integer;
  last_nonopt: Integer;

{* Exchange two adjacent subsequences of ARGV.
   One subsequence is elements [first_nonopt,last_nonopt)
   which contains all the non-options that have been skipped so far.
   The other is elements [last_nonopt,optind), which contains all
   the options processed since those non-options were skipped.

   `first_nonopt' and `last_nonopt' are relocated so that they describe
   the new indices of the non-options in ARGV after they are moved.  *}

procedure exchange(argv: array of PAnsiChar);
var
  bottom, middle, top: Integer;
  i, len: Integer;
  tem: PAnsiChar;
begin
  bottom := first_nonopt;
  middle := last_nonopt;
  top := optind;
  while ((top > middle) and (middle > bottom)) do
  begin
    if (top - middle > middle - bottom) then
    begin
      {* Bottom segment is the short one.  *}
      len := middle - bottom;
      {* Swap it with the top part of the top segment.  *}
      for i := 0 to len - 1 do
      begin
        tem := argv[bottom + 1];
        argv[bottom + i] := argv[top - (middle - bottom) + i];
        argv[top - (middle - bottom) + i] := tem;
      end;
      {* Exclude the moved bottom segment from further swapping.  *}
      top := top - len;
    end else begin
      {* Top segment is the short one.  *}
      len := top - middle;
      {* Swap it with the bottom part of the bottom segment.  *}
      for i := 0 to len - 1 do
      begin
        tem := argv[bottom + i];
        argv[bottom + i] := argv[middle + i];
        argv[middle + i] := tem;
      end;
      {* Exclude the moved top segment from further swapping.  *}
      bottom := bottom + len;
    end;
  end;
  {* Update records for the slots the non-options now occupy.  *}
  first_nonopt := first_nonopt + (optind - last_nonopt);
  last_nonopt := optind;
end;

{* Initialize the internal data when the first call is made.  *}
function _getopt_initialize(optstring: PAnsiChar): PAnsiChar;
begin
  {* Start processing options with ARGV-element 1 (since ARGV-element 0
   is the program name); the sequence of previously skipped
   non-option ARGV-elements is empty.  *}
  first_nonopt := optind + 1;
  last_nonopt := optind + 1;
  nextchar := nil;
  GetMem(nextchar, MAX_PATH);
  ZeroMemory(nextchar, MAX_PATH);
  GetEnvironmentVariable('POSIXLY_CORRECT', nextchar, MAX_PATH);
  {* Determine how to handle the ordering of options and nonoptions.  *}
  if optstring^ = '-' then
  begin
    ordering := RETURN_IN_ORDER;
    Inc(optstring);
  end else if optstring^ = '+' then
  begin
    ordering := REQUIRE_ORDER;
    Inc(optstring);
  end else if posixly_correct <> nil then
    ordering := REQUIRE_ORDER
  else
    ordering := PERMUTE;
  Result := optstring;
end;

{* Scan elements of ARGV (whose length is ARGC) for option characters
   given in OPTSTRING.

   If an element of ARGV starts with '-', and is not exactly "-" or "--",
   then it is an option element.  The characters of this element
   (aside from the initial '-') are option characters.  If `getopt'
   is called repeatedly, it returns successively each of the option characters
   from each of the option elements.

   If `getopt' finds another option character, it returns that character,
   updating `optind' and `nextchar' so that the next call to `getopt' can
   resume the scan with the following option character or ARGV-element.

   If there are no more option characters, `getopt' returns `EOF'.
   Then `optind' is the index in ARGV of the first ARGV-element
   that is not an option.  (The ARGV-elements have been permuted
   so that those that are not options now come last.)

   OPTSTRING is a string containing the legitimate option characters.
   If an option character is seen that is not listed in OPTSTRING,
   return '?' after printing an error message.  If you set `opterr' to
   zero, the error message is suppressed but we still return '?'.

   If a char in OPTSTRING is followed by a colon, that means it wants an arg,
   so the following text in the same ARGV-element, or the text of the following
   ARGV-element, is returned in `optarg'.  Two colons mean an option that
   wants an optional arg; if there is text in the current ARGV-element,
   it is returned in `optarg', otherwise `optarg' is set to zero.

   If OPTSTRING starts with `-' or `+', it requests different methods of
   handling the non-option ARGV-elements.
   See the comments about RETURN_IN_ORDER and REQUIRE_ORDER, above.

   Long-named options begin with `--' instead of `-'.
   Their names may be abbreviated as long as the abbreviation is unique
   or is an exact match for some defined option.  If they have an
   argument, it follows the option name in the same ARGV-element, separated
   from the option name by a `=', or else the in next ARGV-element.
   When `getopt' finds a long-named option, it returns 0 if that option's
   `flag' field is nonzero, the value of the option's `val' field
   if the `flag' field is zero.

   The elements of ARGV aren't really const, because we permute them.
   But we pretend they're const in the prototype to be compatible
   with other systems.

   LONGOPTS is a vector of `struct option' terminated by an
   element containing a name which is zero.

   LONGIND returns the index in LONGOPT of the long-named option found.
   It is only valid when a long-named option has been found by the most
   recent call.

   If LONG_ONLY is nonzero, '-' as well as '--' can introduce
   long-named options.  *}

function _getopt_internal(argc: Integer; const argv: array of PAnsiChar;
  optstring: PAnsiChar; const longopts: option; longind: PInteger;
  long_only: Integer): Integer;
begin
  Result := -1;
  optarg := nil;
  if optind = 0 then
    optstring := _getopt_initialize(optstring);
  if (nextchar = nil) or (nextchar^ = #0) then
  begin
    {* Advance to the next ARGV-element.  *}
    if ordering = PERMUTE then
    begin
      {* If we have just processed some options following some non-options,
	     exchange them so that the options come first.  *}
      if (first_nonopt <> last_nonopt) and (last_nonopt <> optind) then
        exchange(argv)
      else if last_nonopt <> optind then
        first_nonopt := optind;
      {* Skip any additional non-options
	     and extend the range of non-options previously skipped.  *}
      while (optind < argc) and ((argv[optind]^ <> '-') or
        (PAnsiChar(Integer(argv[optind]) + SizeOf(AnsiChar))^ <> #0)) do
      begin
        Inc(optind);
      end;
      last_nonopt := optind;
    end;
    {* The special ARGV-element `--' means premature end of options.
     Skip it like a null option,
     then exchange with previous non-options as if it were an option,
     then skip everything else like a non-option.  *}
    if (optind <> argc) and (lstrcmp(argv[optind], '--') = 0) then
    begin
      Inc(optind);

      if (first_nonopt <> last_nonopt) and (last_nonopt <> optind) then
        exchange(argv)
      else if first_nonopt = last_nonopt then
        first_nonopt := optind;
      last_nonopt := argc;

      optind := argc;
    end;
    {* If we have done all the ARGV-elements, stop the scan
	    and back over any non-options that we skipped and permuted.  *}
    if optind = argc then
    begin
      {* Set the next-arg-index to point at the non-options
	     that we previously skipped, so the caller will digest them.  *}
      if first_nonopt <> last_nonopt then
        optind := first_nonopt;
      Exit;
    end;
    {* If we have come to a non-option and did not permute it,
  	 either stop the scan or describe it to the caller and pass it by.  *}

    if ((argv[optind]^ <> '-') or
      (PAnsiChar(Integer(argv[optind]) + SizeOf(AnsiChar))^ = #0)) then
    begin
      if ordering = REQUIRE_ORDER then
        Exit;
      optarg := argv[optind];
      Inc(optind);
      Result := 1;
      Exit;
    end;
    {* We have found another option-ARGV-element.
	    Skip the initial punctuation.  *}
//    nextchar := ()
  end;
end;

      //* We have found another option-ARGV-element.
	 Skip the initial punctuation.  */

      nextchar = (argv[optind] + 1
		  + (longopts != NULL && argv[optind][1] == '-'));
    }

  /* Decode the current option-ARGV-element.  */

  /* Check whether the ARGV-element is a long option.

     If long_only and the ARGV-element has the form "-f", where f is
     a valid short option, don't consider it an abbreviated form of
     a long option that starts with f.  Otherwise there would be no
     way to give the -f short option.

     On the other hand, if there's a long option "fubar" and
     the ARGV-element is "-fu", do consider that an abbreviation of
     the long option, just like "--fu", and not "-f" with arg "u".

     This distinction seems to be the most useful approach.  */

  if (longopts != NULL
      && (argv[optind][1] == '-'
	  || (long_only && (argv[optind][2] || !my_index (optstring, argv[optind][1])))))
    {
      char *nameend;
      const struct option *p;
      const struct option *pfound = NULL;
      int exact = 0;
      int ambig = 0;
      int indfound;
      int option_index;

      for (nameend = nextchar; *nameend && *nameend != '='; nameend++)
	/* Do nothing.  */ ;

      /* Test all long options for either exact match
	 or abbreviated matches.  */
      for (p = longopts, option_index = 0; p->name; p++, option_index++)
	if (!strncmp (p->name, nextchar, nameend - nextchar))
	  {
	    if (nameend - nextchar == strlen (p->name))
	      {
		/* Exact match found.  */
		pfound = p;
		indfound = option_index;
		exact = 1;
		break;
	      }
	    else if (pfound == NULL)
	      {
		/* First nonexact match found.  */
		pfound = p;
		indfound = option_index;
	      }
	    else
	      /* Second or later nonexact match found.  */
	      ambig = 1;
	  }

      if (ambig && !exact)
	{
	  if (opterr)
	    fprintf (stderr, "%s: option `%s' is ambiguous\n",
		     argv[0], argv[optind]);
	  nextchar += strlen (nextchar);
	  optind++;
	  return '?';
	}

      if (pfound != NULL)
	{
	  option_index = indfound;
	  optind++;
	  if (*nameend)
	    {
	      /* Don't test has_arg with >, because some C compilers don't
		 allow it to be used on enums.  */
	      if (pfound->has_arg)
		optarg = nameend + 1;
	      else
		{
		  if (opterr)
		    {
		      if (argv[optind - 1][1] == '-')
			/* --option */
			fprintf (stderr,
				 "%s: option `--%s' doesn't allow an argument\n",
				 argv[0], pfound->name);
		      else
			/* +option or -option */
			fprintf (stderr,
			     "%s: option `%c%s' doesn't allow an argument\n",
			     argv[0], argv[optind - 1][0], pfound->name);
		    }
		  nextchar += strlen (nextchar);
		  return '?';
		}
	    }
	  else if (pfound->has_arg == 1)
	    {
	      if (optind < argc)
		optarg = argv[optind++];
	      else
		{
		  if (opterr)
		    fprintf (stderr, "%s: option `%s' requires an argument\n",
			     argv[0], argv[optind - 1]);
		  nextchar += strlen (nextchar);
		  return optstring[0] == ':' ? ':' : '?';
		}
	    }
	  nextchar += strlen (nextchar);
	  if (longind != NULL)
	    *longind = option_index;
	  if (pfound->flag)
	    {
	      *(pfound->flag) = pfound->val;
	      return 0;
	    }
	  return pfound->val;
	}

      /* Can't find it as a long option.  If this is not getopt_long_only,
	 or the option starts with '--' or is not a valid short
	 option, then it's an error.
	 Otherwise interpret it as a short option.  */
      if (!long_only || argv[optind][1] == '-'
	  || my_index (optstring, *nextchar) == NULL)
	{
	  if (opterr)
	    {
	      if (argv[optind][1] == '-')
		/* --option */
		fprintf (stderr, "%s: unrecognized option `--%s'\n",
			 argv[0], nextchar);
	      else
		/* +option or -option */
		fprintf (stderr, "%s: unrecognized option `%c%s'\n",
			 argv[0], argv[optind][0], nextchar);
	    }
	  nextchar = (char *) "";
	  optind++;
	  return '?';
	}
    }

  /* Look at and handle the next short option-character.  */

  {
    char c = *nextchar++;
    char *temp = my_index (optstring, c);

    /* Increment `optind' when we start to process its last character.  */
    if (*nextchar == '\0')
      ++optind;

    if (temp == NULL || c == ':')
      {
	if (opterr)
	  {
	    if (posixly_correct)
	      /* 1003.2 specifies the format of this message.  */
	      fprintf (stderr, "%s: illegal option -- %c\n", argv[0], c);
	    else
	      fprintf (stderr, "%s: invalid option -- %c\n", argv[0], c);
	  }
	optopt = c;
	return '?';
      }
    if (temp[1] == ':')
      {
	if (temp[2] == ':')
	  {
	    /* This is an option that accepts an argument optionally.  */
	    if (*nextchar != '\0')
	      {
		optarg = nextchar;
		optind++;
	      }
	    else
	      optarg = NULL;
	    nextchar = NULL;
	  }
	else
	  {
	    /* This is an option that requires an argument.  */
	    if (*nextchar != '\0')
	      {
		optarg = nextchar;
		/* If we end this ARGV-element by taking the rest as an arg,
		   we must advance to the next element now.  */
		optind++;
	      }
	    else if (optind == argc)
	      {
		if (opterr)
		  {
		    /* 1003.2 specifies the format of this message.  */
		    fprintf (stderr, "%s: option requires an argument -- %c\n",
			     argv[0], c);
		  }
		optopt = c;
		if (optstring[0] == ':')
		  c = ':';
		else
		  c = '?';
	      }
	    else
	      /* We already incremented `optind' once;
		 increment it again when taking next ARGV-elt as argument.  */
	      optarg = argv[optind++];
	    nextchar = NULL;
	  }
      }
    return c;
  }
}

function getopt_long(argc: Integer; const argv: PAnsiChar;
  const shortopts: PAnsiChar; const longopts: option;
  longind: PInteger): Integer;
begin

end;

function getopt_long_only(argc: Integer; const argv: PAnsiChar;
  const shortopts: PAnsiChar; const longopt: option;
  longind: PInteger): Integer;
begin

end;

end.
