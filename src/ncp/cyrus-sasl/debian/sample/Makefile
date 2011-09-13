#!/usr/bin/make -f

INCDIR=$(T)/include
LIBDIR=$(T)/lib/.libs

all: sample-server sample-client

sample-server: sample-server.c
	gcc -g -o sample-server sample-server.c -I. -I$(INCDIR) -L$(LIBDIR) -lsasl2

sample-client: sample-client.c
	gcc -g -o sample-client sample-client.c -I. -I$(INCDIR) -L$(LIBDIR) -lsasl2
