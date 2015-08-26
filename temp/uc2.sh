#!/bin/sh

st=$1
                if($st=~/^[0-9A-F]+$/i){
                        $st = pack(«H*», $st);
                        encode(«ucs-2»,$st); # mark that bytestring is in ucs2
                        from_to($st,«ucs-2»,«utf-8»); # actually recode
                }
                return $st;
