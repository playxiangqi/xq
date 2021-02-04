#------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------
.PHONY: start
start:
	@cd xq_portal && mix phx.server

.PHONY: setup
setup:
	@cd xq_app && yarn
	@cd xq_portal && mix phx.setup
