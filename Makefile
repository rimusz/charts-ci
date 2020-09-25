TAG_ARGS ?=

# If the first argument is "tag"
ifneq ( $(filter wordlist 1,tag), $(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "tag"
  TAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(TAG_ARGS):;@:)
endif

.PHONY: tag
tag:
	$(eval export TAG_ARGS)
	@scripts/tag.sh
