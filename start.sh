#!/bin/sh

erl -pa ebin -eval 'application:start(inets), application:start(extreme), toolbar:start()'
