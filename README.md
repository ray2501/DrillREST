
DrillREST
=====

[Apache Drill] (https://drill.apache.org/) is a low-latency distributed query engine for large-scale datasets,
including structured and semi-structured/nested data.

You can connect to Apache Drill through the following interfaces:
 * JDBC
 * ODBC
 * Drill shell
 * Drill Web Console, [REST API] (https://drill.apache.org/docs/rest-api/)

This extension is an Apache Drill REST Client Library for [Tcl] (http://tcl.tk).
The library consists of a single [Tcl Module] (http://tcl.tk/man/tcl8.6/TclCmd/tm.htm#M9) file.

DrillREST is using Tcl built-in package http to send request to Apache Drill server and get response.

This extension needs Tcl 8.6 and tcllib json::write package.


Interface
=====

The library has 1 TclOO class, DrillREST.


Example
=====

## Check Apache Drill version

    package require DrillREST
    package require json

    set mydrill [DrillREST new http://localhost:8047]
    set result [$mydrill query "select version from sys.version"]

    set parse_result [json::json2dict $result]
    puts "Apache Drill version"
    puts "=========="

    set rows [dict get $parse_result rows]
    foreach row $rows {
        foreach {key value} $row {
            if {[string compare $key "version"]==0} {
                puts "$value"
            }
        }
    }

## Querying a JSON File

Apache Drill provides sample data, try it:

    package require DrillREST
    package require json

    set mydrill [DrillREST new http://localhost:8047]
    set result [$mydrill query "SELECT * FROM cp.`employee.json` LIMIT 3"]

    set parse_result [json::json2dict $result]
    set rows [dict get $parse_result rows]
    foreach row $rows {
        puts "=================="
        foreach {key value} $row {
            puts "$key - $value"
        }
    }

## Querying a [Parquet] (https://parquet.apache.org/) File

Query the region.parquet and nation.parquet files in the sample-data directory on your local file system.
To view the data in the region.parquet file, use the actual path to your Drill installation to construct this query:

    package require DrillREST
    package require json

    set mydrill [DrillREST new http://localhost:8047]
    set result [$mydrill query "SELECT * FROM \
        dfs.`/home/danilo/Programs/apache-drill-1.6.0/sample-data/region.parquet`"]

    set parse_result [json::json2dict $result]
    set rows [dict get $parse_result rows]
    foreach row $rows {
        puts "=================="
        foreach {key value} $row {
            puts "$key - $value"
        }
    }

## HTTPS support

If user enables HTTPS support, below is an example:

    package require DrillREST
    package require json

    set mydrill [DrillREST new https://localhost:8047 1]

Please notice, I use [TLS extension] (http://tls.sourceforge.net/) to add https support.
So https support needs TLS extension.

## User Authentication

Drill currently supports username/password based authentication through the use of the Linux Pluggable Authentication Module (PAM).
Drill 1.5 extends Drill user authentication to the Web Console and underlying REST API.

Below is an example (please remember to setup username and password variable):

    package require DrillREST
    package require json

    set mydrill [DrillREST new https://localhost:8047 1]
    $mydrill login $username $password
    set result [$mydrill query "select version from sys.version"]

    set parse_result [json::json2dict $result]
    puts "Apache Drill version"
    puts "=========="

    set rows [dict get $parse_result rows]
    foreach row $rows {
        foreach {key value} $row {
            if {[string compare $key "version"]==0} {
                puts "$value"
            }
        }
    }

    # I just connect to /logout address and get status code
    $mydrill logout

I download [jpam] (https://sourceforge.net/projects/jpam/) to test this function.
REST API user authentication works but I think it is not a mature function.
Or I need to research more for this item if possible.

