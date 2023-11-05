#
# Copyright 2022 Ivo Woltring <WebMaster@ivonet.nl>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= makefile.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

DOCKERFILES=$(shell find * -type f -depth 1 -name Dockerfile)
IMAGES=$(subst /,\:,$(subst /Dockerfile,,$(DOCKERFILES)))
RELEASE_IMAGE_TARGETS=$(addprefix release-,$(IMAGES))
TAG_IMAGE_TARGETS=$(addprefix tag-,$(IMAGES))
MULTI_IMAGE_TARGETS=$(addprefix multi-,$(IMAGES))
X86_TARGETS=$(addprefix x86-,$(IMAGES))
VERSION_IMAGE_TARGETS=$(addprefix version-,$(IMAGES))
NO_CACHE_TARGETS=$(addprefix nc-,$(IMAGES))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help $(IMAGES) $(RELEASE_IMAGE_TARGETS)

help: projects ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST);
	@echo ">>> make sure to have 'jq' installed."

.DEFAULT_GOAL := help

projects: ## prints which projects have build targets
	@for fo in $(IMAGES);                                                                 \
	do                                                                                    \
		echo $$fo | awk '{printf "\033[36m%-30s\033[0m Builds %s\n", $$1, $$1}';          \
		echo $$fo | awk '{printf "\033[36mtag-%-26s\033[0m Tags %s\n", $$1, $$1}';        \
		echo $$fo | awk '{printf "\033[36mrelease-%-22s\033[0m Releases %s\n", $$1, $$1}';\
		echo $$fo | awk '{printf "\033[36mmulti-%-24s\033[0m multi platform release %s\n", $$1, $$1}';\
		echo $$fo | awk '{printf "\033[36mnc-%-27s\033[0m no cache build %s\n", $$1, $$1}';\
		echo $$fo | awk '{printf "\033[36mx86-%-27s\033[0m no cache build %s\n", $$1, $$1}';\
	done

$(IMAGES): %: ## builds a specific project by its directory name
	@project=$(subst :,/,$@);                                                 \
	preparation_script="$$project/pre-make.sh";                               \
	if [ -f "$$preparation_script" ];                                         \
	then                                                                      \
		echo "Using pre-make.sh script for preparation...";                   \
		cd "$$project";                                                       \
		pre-make.sh;                                                          \
		cd ..;                                                                \
	fi;                                                                       \
	make_script="$$project/make.sh";                                          \
	if [ -f "$$make_script" ];                                                \
	then                                                                      \
		echo "Using the make.sh in stead of standard build";                  \
		cd "$$project";                                                       \
		make.sh;                                                              \
		cd ..;                                                                \
	else                                                                      \
		docker build $(ARG) --platform=linux/arm64/v8 -t $(REGISTRY)/$@ $(subst :,/,$@);  \
	fi;

$(NO_CACHE_TARGETS): %: ## builds a specific project by its directory name in no-cache mode
	@project=$(subst nc-,,$@);                                                \
	preparation_script="$$project/pre-make.sh";                               \
	if [ -a "$$preparation_script" ];                                         \
	then                                                                      \
	    echo "Using pre-make.sh script for preparation...";                   \
		cd "$$project";                                                       \
        pre-make.sh;                                                          \
        cd ..;                                                                \
    fi;                                                                       \
    docker builder prune -f;                                                  \
    docker build --no-cache -t $(REGISTRY)/$$project $$project;

$(RELEASE_IMAGE_TARGETS): %: ## release a single image from the project
	@project=$(subst release-,,$@);                                           \
	versionfile="$$project/VERSION";                                          \
	MY_APP_VERSION=$(VERSION);                                                \
	if [ -a "$$versionfile" ];                                                \
	then                                                                      \
		MY_APP_VERSION=`cat $$versionfile`;                                   \
	fi;                                                                       \
	preparation_script="$$project/pre-make.sh";                               \
	if [ -a "$$preparation_script" ];                                         \
	then                                                                      \
	    echo "Using pre-make.sh script for preparation...";                   \
		cd "$$project";                                                       \
        pre-make.sh;                                                          \
        cd ..;                                                                \
    fi;                                                                       \
	docker build -t $(REGISTRY)/$$project $(subst :,/,$$project);             \
	docker tag $(REGISTRY)/$$project:latest $(REGISTRY)/$$project:$$MY_APP_VERSION; \
	docker push $(REGISTRY)/$$project:latest;                                 \
	docker push $(REGISTRY)/$$project:$$MY_APP_VERSION;

$(MULTI_IMAGE_TARGETS): %: buildx ## release a multi-platform image from the project
	@project=$(subst multi-,,$@);                                             \
	versionfile="$$project/VERSION";                                          \
	MY_APP_VERSION=$(VERSION);                                                \
	if [ -a "$$versionfile" ];                                                \
	then                                                                      \
		MY_APP_VERSION=`cat $$versionfile`;                                   \
	fi;                                                                       \
	preparation_script="$$project/pre-make.sh";                               \
	if [ -a "$$preparation_script" ];                                         \
	then                                                                      \
	    echo "Using pre-make.sh script for preparation...";                   \
		cd "$$project";                                                       \
        pre-make.sh;                                                          \
        cd ..;                                                                \
    fi;                                                                       \
	docker buildx build $(ARG) --no-cache --platform=linux/amd64,linux/arm64/v8 --push -t $(REGISTRY)/$$project $(subst :,/,$$project);  \
	docker buildx build $(ARG) --no-cache --platform=linux/amd64,linux/arm64/v8 --push -t $(REGISTRY)/$$project:$$MY_APP_VERSION $(subst :,/,$$project); \
	docker pull $(REGISTRY)/$$project:latest;

$(X86_TARGETS): %: buildx ## release a native x86 image from the project
	@project=$(subst x86-,,$@);                                               \
	versionfile="$$project/VERSION";                                          \
	MY_APP_VERSION=$(VERSION);                                                \
	if [ -a "$$versionfile" ];                                                \
	then                                                                      \
		MY_APP_VERSION=`cat $$versionfile`;                                   \
	fi;                                                                       \
	preparation_script="$$project/pre-make.sh";                               \
	if [ -a "$$preparation_script" ];                                         \
	then                                                                      \
	    echo "Using pre-make.sh script for preparation...";                   \
		cd "$$project";                                                       \
        pre-make.sh;                                                          \
        cd ..;                                                                \
    fi;                                                                       \
    docker buildx prune -f;                                                   \
	docker buildx build --platform=linux/amd64 --push -t $(REGISTRY)/$$project $(subst :,/,$$project);  \
	docker buildx build --platform=linux/amd64 --push -t $(REGISTRY)/$$project:$$MY_APP_VERSION $(subst :,/,$$project);

$(TAG_IMAGE_TARGETS): %: ## tag a single image from the project
	@project=$(subst tag-,,$@);                                               \
	versionfile="$$project/VERSION";                                          \
	MY_APP_VERSION=$(VERSION);                                                \
	if [ -a "$$versionfile" ];                                                \
	then                                                                      \
		MY_APP_VERSION=`cat $$versionfile`;                                   \
		echo "$(REGISTRY)/$$project version override: $$MY_APP_VERSION";      \
	fi;                                                                       \
	echo "Tagging $$project as: $(REGISTRY)/$$project:$$MY_APP_VERSION";      \
	docker tag $(REGISTRY)/$$project:latest $(REGISTRY)/$$project:$$MY_APP_VERSION;

buildx: ## initialize multi-platform builder
	 @if [ `docker ps |grep localremote_builder|wc -l` -ne 1 ];               \
	 then                                                                     \
		docker buildx create --name localremote_builder --node localremote_builder --platform linux/arm64,linux/riscv64,linux/ppc64le,linux/s390x,linux/mips64le,linux/mips64,linux/arm/v7,linux/arm/v6 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10000000 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=10000000; \
		docker buildx create --name localremote_builder --append --node intelarch --platform linux/amd64,linux/386 ssh://nas --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10000000 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=10000000; \
		docker buildx use localremote_builder;                                \
		docker buildx inspect --bootstrap;                                    \
	fi

prune: ## Prune
	@echo "Pruning the docker system...";                                     \
	docker system prune -f;                                                   \
	docker buildx prune -f;


rmbuildx: prune ## removes the multi-platform builder
	@if [ `docker ps |grep localremote_builder|wc -l` -eq 1 ];                \
	then                                                                      \
		docker buildx rm -f localremote_builder;                              \
	fi

build: ## Build all the images in the project as 'latest'
	@for img in $(IMAGES);                                                    \
	do                                                                        \
	    project=$(subst :,/,$$img);                                           \
		preparation_script="$$project/pre-make.sh";                           \
		if [ -a "$$preparation_script" ];                                     \
		then                                                                  \
		    echo "Using pre-make.sh script for preparation...";               \
			cd "$$project";                                                   \
	        pre-make.sh;                                                      \
	        cd ..;                                                            \
	    fi;                                                                   \
		docker build  -t $(REGISTRY)/$$img $(subst :,/,$$project);             \
	done

build-nc: ## Build all the images in the project as 'latest' (no-cache)
	@for img in $(IMAGES);                                                    \
	do                                                                        \
	    project=$(subst :,/,$$img);                                           \
		preparation_script="$$project/pre-make.sh";                           \
		if [ -a "$$preparation_script" ];                                     \
		then                                                                  \
		    echo "Using pre-make.sh script for preparation...";              \
			cd "$$project";                                                   \
	        pre-make.sh;                                                     \
	        cd ..;                                                            \
	    fi;                                                                   \
		docker build --no-cache -t $(REGISTRY)/$$img $(subst :,/,$$project);  \
	done                                                                      \

tag: ## Tags all the images to the VERSION as found in the VERSION or makefile.env file
	@for img in $(IMAGES);                                                    \
	do                                                                        \
	    versionfile="$$img/VERSION";                                          \
		MY_APP_VERSION=$(VERSION);                                            \
		if [ -a "$$versionfile" ];                                            \
		then                                                                  \
			MY_APP_VERSION=`cat $$versionfile`;                               \
		    echo "$(REGISTRY)/$$img version override: $$MY_APP_VERSION";      \
		fi;                                                                   \
		docker tag $(REGISTRY)/$$img:latest $(REGISTRY)/$$img:$$MY_APP_VERSION;\
	done

versioning: ## Prints all project versions (created if tagged/released)
	@for img in $(IMAGES);                                                    \
	do                                                                        \
	    versionfile="$$img/VERSION";                                          \
		MY_APP_VERSION=$(VERSION);                                            \
		if [ -a "$$versionfile" ];                                            \
		then                                                                  \
			MY_APP_VERSION=`cat $$versionfile`;                               \
		fi;                                                                   \
		echo "$(REGISTRY)/$$img:$$MY_APP_VERSION";                            \
	done

version: build tag ## Builds and versions all the images in this project

release: build-nc publish ## Make a release by building and publishing the `{version}` and `latest` tagged containers to the registry

publish: publish-latest publish-version ## Publish the `{version}` and `latest` tagged containers to the registry

publish-latest:
	@for img in $(IMAGES); do                                                 \
		docker push $(REGISTRY)/$$img:latest ;                                \
	done

publish-version: tag
	@for img in $(IMAGES); do                                                 \
	    versionfile="$$img/VERSION";                                          \
		MY_APP_VERSION=$(VERSION);                                            \
		if [ -a "$$versionfile" ];                                            \
		then                                                                  \
			MY_APP_VERSION=`cat $$versionfile`;                               \
		    echo "$(REGISTRY)/$$img version override: $$MY_APP_VERSION";      \
		fi;                                                                   \
		docker push $(REGISTRY)/$$img:$$MY_APP_VERSION ;                      \
	done

clean: rmc dangling ## Cleans up the mess you made while building and running
	@docker builder prune -f; \
	docker images;

cleaner: clean rmi ## Same as clean plus the build images

cleanest: cleaner rmi-base-images ## Same as cleaner plus removal of base images

dangling: ## Cleans dangling images in general
	@echo "Cleaning dangling images";                                         \
	docker rmi $$(docker images --filter dangling=true -q 2>/dev/null) 2> /dev/null || true; \
    docker rmi $$(docker images | grep "^<none>" | awk '{print $3}') 2> /dev/null || true; \

rmi: rmi-version rmi-latest ## Removes all images from this project with their versions

rmi-version: ## Removes all the local images from this project with the defined version
	@echo Removing all current versions for this project;                     \
	for cont in $$(docker images -q|uniq);                                    \
	do                                                                        \
		for img in $(IMAGES);                                                 \
		do                                                                    \
			versionfile="$$img/VERSION";                                      \
			MY_APP_VERSION=$(VERSION);                                        \
			if [ -a "$$versionfile" ];                                        \
			then                                                              \
				MY_APP_VERSION=`cat $$versionfile`;                           \
			fi;                                                               \
			idx=$$(docker inspect $$cont|jq ".[0].RepoTags | index(\"$(REGISTRY)/$$img:$$MY_APP_VERSION\")");\
			if [ "$$idx" != "null" ];                                         \
			then                                                              \
				docker rmi $(REGISTRY)/$$img:$$MY_APP_VERSION 2>/dev/null;    \
			fi;                                                               \
		done;                                                                 \
	done

rmi-latest: ## Removes all the local images from this project with the 'latest' tag
	@echo Removing all images with version 'latest' from this project;        \
	for cont in $$(docker images -q|uniq);                                         \
	do                                                                        \
		for img in $(IMAGES);                                                 \
		do                                                                    \
			idx=$$(docker inspect $$cont|jq ".[0].RepoTags | index(\"$(REGISTRY)/$$img:latest\")");\
			if [ "$$idx" != "null" ];                                         \
			then                                                              \
				docker rmi $(REGISTRY)/$$img:latest 2>/dev/null;              \
			fi                                                                \
		done                                                                  \
	done

rmi-base-images: ## Removes all the base (FROM) images used in the projects
	@echo "Removing all the base (FROM) images used in the projects";         \
	baseimgs=$$(find . -type f -name Dockerfile -exec grep ^FROM {} \; | sed 's/FROM //g');\
	for base in $$baseimgs;                                                   \
	do                                                                        \
	    noversion=$$(echo $$base|sed 's/:.*//');                              \
	    if [ "$$noversion" == "$$base" ];                                     \
	    then                                                                  \
	       echo "No version fount, assumong latest";                          \
	       base="$$base:latest";                                              \
	    fi;                                                                   \
	    echo "$$base";                                                        \
		for cont in $$(docker images -q);                                     \
		do                                                                    \
		    cname=$$(docker inspect $$cont|jq '.[0].RepoTags[0]'|sed 's/\"//g') ; \
			if [ $$base == $$cname ];                                         \
			then                                                              \
        	    echo "Removing base-image: $$base";                           \
				docker rmi $$base 2>/dev/null;                                \
			fi                                                                \
		done                                                                  \
	done

rmc: stop ## Stops and removes running containers based on the images in this project
	@echo Removing all created containers from this project;                  \
	for cont in $$(docker ps -aq);                                            \
	do                                                                        \
		cname=$$(docker inspect $$cont | jq .[].Config.Image | sed 's/\"//g');\
		for img in $(IMAGES);                                                 \
		do                                                                    \
			if [ $(REGISTRY)/$$img == $$cname ];                              \
			then                                                              \
				echo Removing container: $$cname -\> $$cont;                  \
				docker rm -f $$cont >/dev/null;                               \
			fi;                                                               \
			versionfile="$$img/VERSION";                                      \
			MY_APP_VERSION=$(VERSION);                                        \
			if [ -a "$$versionfile" ];                                        \
			then                                                              \
				MY_APP_VERSION=`cat $$versionfile`;                           \
			fi;                                                               \
			if [ $(REGISTRY)/$$img:$$MY_APP_VERSION == $$cname ];             \
			then                                                              \
				echo Stopping container: $$cname -\> $$cont;                  \
				docker rm -f $$cont >/dev/null;                               \
			fi                                                                \
		done                                                                  \
	done

stop: ## Stops all running containers based on the images in this project
	@echo Stopping all running containers from this project;                  \
	for cont in $$(docker ps -q);                                             \
	do                                                                        \
		cname=$$(docker inspect $$cont | jq .[].Config.Image | sed 's/\"//g');\
		for img in $(IMAGES);                                                 \
		do                                                                    \
			if [ $(REGISTRY)/$$img == $$cname ];                              \
			then                                                              \
				echo Stopping container: $$cname -\> $$cont;                  \
				docker stop $$cont >/dev/null;                                \
			fi;                                                               \
			versionfile="$$img/VERSION";                                      \
			MY_APP_VERSION=$(VERSION);                                        \
			if [ -a "$$versionfile" ];                                        \
			then                                                              \
				MY_APP_VERSION=`cat $$versionfile`;                           \
			fi;                                                               \
			if [ $(REGISTRY)/$$img:$$MY_APP_VERSION == $$cname ];             \
			then                                                              \
				echo Stopping container: $$cname -\> $$cont;                  \
				docker stop $$cont >/dev/null;                                \
			fi                                                                \
		done                                                                  \
	done
