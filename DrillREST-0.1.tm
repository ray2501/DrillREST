# DrillREST --
#
#	Drill REST Client Library for Tcl
#
# Copyright (C) 2016 Danilo Chang <ray2501@gmail.com>
#
# Retcltribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Retcltributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Retcltributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

package require Tcl 8.6
package require TclOO
package require http
package require json::write

package provide DrillREST 0.1

oo::class create DrillREST {
    variable server

    constructor {{SERVER http://localhost:8047}} {
        set server $SERVER
    }

    destructor {
    }

    method send_request {url method {headers ""} {needstate 0} {data ""}} {
        variable tok

        if {[string length $data] < 1} {
            if {[catch {set tok [http::geturl $url -method $method \
                -headers $headers]}]} {
                return "error"
            }
        } else {
            if {[catch {set tok [http::geturl $url -method $method \
                -headers $headers -query $data]}]} {
                return "error"
            }
        }

        if {$needstate != 0} {
            set res [http::status $tok]
        } else {
            set res [http::data $tok]
        }

        http::cleanup $tok
        return $res
    }

    method query {sql_query} {
        variable sql_string

        set sql_string [::json::write object \
                        "queryType" "\"SQL\"" "query" "\"$sql_query\""]
        set myurl "$server/query.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        set res [my send_request $myurl POST $headerl 0 $sql_string]
        return $res
    }

    method getProfiles {} {
        set myurl "$server/profiles.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        set res [my send_request $myurl GET $headerl]
        return $res
    }

    method getStorage {} {
        set myurl "$server/storage.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        set res [my send_request $myurl GET $headerl]
        return $res
    }

    method getStats {} {
        set myurl "$server/stats.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        set res [my send_request $myurl GET $headerl]
        return $res
    }

    method getOptions {} {
        set myurl "$server/options.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        set res [my send_request $myurl GET $headerl]
        return $res
    }
}
