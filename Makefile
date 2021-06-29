APP_PROTO=http
APP_HOST=demo-ci
APP_PORT=8080

test:
	@@if ! curl -vvv $(APP_PROTO)://$(APP_HOST):$(APP_PORT); then \
	    echo FAILED; \
	    exit 1; \
	else \
	    echo SUCCESS; \
	fi;
