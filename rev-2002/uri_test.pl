#!/usr/bin/perl
###############
# Usage:
#
#    uri_test [ -s ] base-URI
#
# where base-URI is a hierarchical URI in absolute form and the -s option
# indicates that we should behave strictly for same-scheme references.
#
# This is a simple test program that uses a non-validating URI reference
# parser to input a sequence of URI references and, for each one,
#
#    1. parse the reference into its component parts
#    2. resolve the reference relative to the base URI argument
#    3. recombine and print the resolved target URI
#
# continuing until end-of-file is received via stdin.
#
# This software is placed in the Public Domain by Roy T. Fielding
# and Day Software, Inc., for use as a test oracle by anyone that
# is testing or implementing a Uniform Resource Identifier parser.
#
# More info: http://gbiv.com/protocols/uri/rev-2002/issues.html
#
###############

$strict = 0;     # set to 1 if you want to reject bad references

$base_uri = shift;
if ($base_uri eq '-s') {
    $strict   = 1;
    $base_uri = shift;
}

die "Usage: $0 [-s] base-URI\n" unless defined($base_uri);

($b_scheme, $b_auth, $b_path, $b_query, $b_frag) = &parse_uri($base_uri);

print<<"END";
  Base URI: $base_uri
    scheme: $b_scheme
 authority: $b_auth
      path: $b_path
     query: $b_query
  fragment: $b_frag

END

print "Enter a URI reference (^D exits): ";

while ($ref = <STDIN>) {

    chomp($ref);

    ($r_scheme, $r_auth, $r_path, $r_query, $r_frag) = &parse_uri($ref);

print<<"END";
 Reference: $ref
    scheme: $r_scheme
 authority: $r_auth
      path: $r_path
     query: $r_query
  fragment: $r_frag

END
    print "Target URI: ",
          &abs_uri($b_scheme, $b_auth, $b_path, $b_query, $b_frag,
                   $r_scheme, $r_auth, $r_path, $r_query, $r_frag), "\n";
}
continue {
    print "\nEnter a URI reference (^D exits): ";
}
print "done\n";
exit(0);

# A component parser based on the regular expression in rfc2396bis
#
sub parse_uri
{
    local($_) = @_;

    if ( m|^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?| ) {
        return ($2, $4, $5, $7, $9);
    }
    return ('this', 'should', 'never', 'happen', undef);
}

# Resolve a URI reference relative to a base URI to obtain target URI
#
sub abs_uri
{
    local($b_scheme, $b_auth, $b_path, $b_query, $b_frag,
          $r_scheme, $r_auth, $r_path, $r_query, $r_frag) = @_;

    local($t_scheme, $t_auth, $t_path, $t_query, $t_frag);

    if (!$strict && ($r_scheme eq $b_scheme)) {
        undef($r_scheme);
    }

    if (defined($r_scheme)) {
        $t_scheme = $r_scheme;
        $t_auth   = $r_auth;
        $t_path   = &remove_dot_segments($r_path);
        $t_query  = $r_query;
    }
    else {
        if (defined($r_auth)) {
            $t_auth  = $r_auth;
            $t_path  = &remove_dot_segments($r_path);
            $t_query = $r_query;
        }
        else {
            if ($r_path =~ /^$/) {
                $t_path = $b_path;
                if (defined($r_query)) {
                    $t_query = $r_query;
                }
                else {
                    $t_query = $b_query;
                }
            }
            elsif ($r_path =~ /^\//) {
                $t_path  = &remove_dot_segments($r_path);
                $t_query = $r_query;
            }
            else {
                $t_path  = &path_merge($b_path, $r_path);
                $t_path  = &remove_dot_segments($t_path);
                $t_query = $r_query;
            }
            $t_auth = $b_auth;
        }
        $t_scheme = $b_scheme;
    }
    $t_frag = $r_frag;

    return &recompose($t_scheme, $t_auth, $t_path, $t_query, $t_frag);
}

# Merge a relative-path reference's path with the base URI's path
#
sub path_merge
{
    local($bpath, $rpath) = @_;

    if ($bpath eq "") {          # base path is empty
        return "/$rpath";
    }
    $bpath =~ s/[^\/]*$//;       # remove last base path segment

    return ($bpath . $rpath);    # and return with ref path appended
}

# Remove "." and ".." segments from a reference's path.
#
# Note that the use of <segment> below refers to a complete path segment,
# bounded by "/" or the beginning or end of the buffer, that may be empty.
#
sub remove_dot_segments
{
    local($_) = @_;
    local($buf) = "";

    # replace any prefix of "../" or "./" with "/"
    #
    s/^\.\.?\//\//;

    while ($_) {

        # replace any prefix segment of "/./" or "/." with "/"
        #
        next if s/^\/\.(\/|$)/\//;

        # replace any prefix segment of "/../" or "/.." with "/"
        #         and remove the last segment added to buffer (if any)
        #
        if (s/^\/\.\.(\/|$)/\//) {
            $buf =~ s/\/?[^\/]*$//;
            next;
        }

        # otherwise, remove the first segment and append it to buffer
        #
        s/^(\/?[^\/]*)//;
        $buf .= $1;
    }

    return $buf;
}

# Given a parsed URI reference, recompose the components into a URI reference
#
sub recompose
{
    local($t_scheme, $t_auth, $t_path, $t_query, $t_frag) = @_;

    local($result) = "";

    if (defined($t_scheme)) {
        $result .= $t_scheme . ':';
    }

    if (defined($t_auth)) {
        $result .= '//' . $t_auth;
    }

    $result .= $t_path;

    if (defined($t_query)) {
        $result .= "?" . $t_query;
    }

    if (defined($t_frag)) {
        $result .= "#" . $t_frag;
    }

    return $result;
}
