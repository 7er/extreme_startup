#!/bin/sh

erl -sname extreme@localhost -pa ebin -eval 'application:start(inets), application:start(extreme), toolbar:start()'
