#-*- Makefile -*-
require DE_EPAGES::Core::API::Makefile;
__DATA__

!OS_SPECIFIC_DEFINES
COMPANY     = FI_GAGAR
CARTRIDGE   = ElectionChoice
MODELS      = "Models/ElectionChoice.zargo"
CVS_BRANCH  = main
STORE       =
RECURSIVE   =
EPAGES_PASSWORD = $(PASSWORD)
EPAGES_TESTSITE = $(STORE)
BUILDFILE=$(DE_EPAGES)/CodeGenerator/Templates/epages/BuildCentralDAL.xml

CVS_CARTRIDGESPATH =RND/epages/epages5/AllOS/Cartridges
CVS_PATH        = $(CVS_CARTRIDGESPATH)/$(COMPANY)/$(CARTRIDGE)
DE_EPAGES   = $(EPAGES_CARTRIDGES)/DE_EPAGES
CARTRIDGES  = $(COMPANY)::$(CARTRIDGE)
COMPANY_CARTRIDGE = COMPANY=$(COMPANY) CARTRIDGE=$(CARTRIDGE) DE_EPAGES="$(DE_EPAGES)"
PRGS = PERL="$(PERL)" MKDIR="$(MKDIR)" RMDIR="$(RMDIR)"

MAKE_GENERATE   = $(MAKE) -f $(DE_EPAGES)/CodeGenerator/Scripts/CodeGenerator.mak $(COMPANY_CARTRIDGE) MODELS=$(MODELS) CVS_BRANCH=$(CVS_BRANCH) CVS_PATH=$(CVS_PATH) BUILDFILE=$(BUILDFILE) $(PRGS)
MAKE_CORE   = $(MAKE) -f $(DE_EPAGES)/Core/Scripts/Core.mak $(COMPANY_CARTRIDGE) $(PRGS)
MAKE_DOC    = $(MAKE) -f $(DE_EPAGES)/SourceDoc/Scripts/SourceDoc.mak $(COMPANY_CARTRIDGE) $(PRGS)
MAKE_INSTALL    = $(MAKE) -f $(DE_EPAGES)/Installer/Scripts/Installer.mak STORE=$(STORE) CARTRIDGES=$(CARTRIDGES) DE_EPAGES="$(DE_EPAGES)" OLDRELEASE=$(OLDRELEASE) NEWRELEASE=$(NEWRELEASE) CVS_CARTRIDGESPATH=$(CVS_CARTRIDGESPATH) $(PRGS) RECURSIVE=$(RECURSIVE)
MAKE_REGISTER   = $(MAKE) -f $(DE_EPAGES)/ShopConfiguration/Scripts/Register.mak CARTRIDGES=$(CARTRIDGES) DE_EPAGES="$(DE_EPAGES)" $(PRGS)

SITE_NAME             = Site
EPAGES_VERSION_NUMBER = $(shell $(AWK) -F= '{gsub(/[[:space:]]/,""); if ($$1 == "EPAGES_VERSION_NUMBER") print $$2}' $(EPAGES_CARTRIDGES)/DE_EPAGES/Makefile.PL)
CACHERESET            = $(PERL) $(DE_EPAGES)/WebInterface/Scripts/StoreCacheReset.pl -storename $(STORE)
INSTALL_STORETYPE     = $(PERL) $(DE_EPAGES)/Installer/Scripts/installStoreType.pl -version $(EPAGES_VERSION_NUMBER)

CARTRIDGE_COVER_DIR=$(EPAGES_WEBSECURE)/coverage
CARTRIDGE_COVER_DB=$(CARTRIDGE_COVER_DIR)/$(COMPANY)-$(CARTRIDGE)/cover_db
!ifndef WINDOWS
WEBURL=$(shell $$PERL $$EPAGES/Cartridges/DE_EPAGES/Object/Scripts/get.pl -storename Site -path "/" ProtocolAndServer | head -n1 | cut -f2 --delimiter="=" )
!endif
makefile: Makefile.PL
	$(PERL) Makefile.PL
	$(PERL) -e "print \"Please restart '$(MAKE)' again makefile was updated.\n\";exit 1;"

clean: makefile
	-$(DEL) .*#* *.pdb
	-$(DEL) makefile
	-$(RMDIR) Generated

generate generate_merge generate_clean generate_update: makefile
	$(MAKE_GENERATE) $@

install uninstall test_patch patch: makefile test_store
	$(MAKE_INSTALL) $@

create_patch cpan: makefile
	$(MAKE_INSTALL) $@

register unregister: makefile
	$(MAKE_REGISTER) $@

sourcedoc: makefile
	$(MAKE_DOC) sourcedoc

test unit_test integration_test regression_test: makefile
	$(MAKE_CORE) $@
	
sonar_reports sonar_properties sonar_scan: makefile
	$(MAKE_CORE) $@

critic_report: makefile
	$(MAKE_CORE) $@

test_coverage collect_coverage coverage_report: makefile
	$(MAKE_CORE) $@ CARTRIDGE_COVER_DB=$(CARTRIDGE_COVER_DB)
!ifndef WINDOWS
	$(ETC_INITD) perm websecure
!endif
	@$(ECHONL) "Check coverage report at URL:"
	@$(ECHONL) "$(WEBURL)/WebSecure/coverage/$(COMPANY)-$(CARTRIDGE)/cover_db/coverage.html"

clean_coverage: makefile
	$(RMDIR) $(CARTRIDGE_COVER_DIR)

test_store: makefile
	$(PERL) -e "exit ('$(STORE)' eq 'YourStore' ? 1 : 0);"

set\STORE_TYPE :
	$(eval STORE_TYPE := $(shell /var/epages/ini-config.sh -f $(EPAGES_CONFIG)/Database.d/$(STORE).conf -s Connection -k StoreType -g))

var\STORE_TYPE var\STORE var\SITE_NAME:
!ifndef WINDOWS
	@[ -n "$($(@F))" ] || { echo "Variable $(@F) not set or invalid, cannot continue" ; exit 127; }
!endif

cache_reset: var\STORE test_store
	$(CACHERESET)

cleanfiles_storetype:
!ifndef EPAGES_IGNORE_STORETYPE
	$(DEL) $(EPAGES_CONFIG)\StoreTypes.d\$(EPAGES_VERSION_NUMBER)\$(STORE_TYPE).conf
	$(RMDIR) $(EPAGES_WEBROOT)\StoreTypes\$(EPAGES_VERSION_NUMBER)\$(STORE_TYPE)
!endif

build_storetype:
	$(INSTALL_STORETYPE) $(CARTRIDGES) -storetype $(STORE_TYPE) -version $(EPAGES_VERSION_NUMBER)
	$(PERL) $(DE_EPAGES)/JQuery/Scripts/DictionaryConverter.pl -cartridge $(CARTRIDGES) -storetype $(STORE_TYPE) -version $(EPAGES_VERSION_NUMBER)
!ifneq ("$(DOJOBUILD)", "0")
	$(MAKE) build_dojo STORE_TYPE=$(STORE_TYPE)
!endif
!ifneq ("$(UIBUILD)", "0")
	$(MAKE) build_ui STORE_TYPE=$(STORE_TYPE)
!endif

build_dojo:
!ifneq ("$(DOJOBUILD)", "0")
	$(PERL) $(EPAGES_CARTRIDGES)/DE_EPAGES/Dojo/Scripts/build.pl -storetype $(STORE_TYPE) -version $(EPAGES_VERSION_NUMBER) -config $(EPAGES_CARTRIDGES)/DE_EPAGES/Dojo/Scripts/build2.conf
	$(PERL) $(EPAGES_CARTRIDGES)/DE_EPAGES/Dojo/Scripts/build.pl -storetype $(STORE_TYPE) -version $(EPAGES_VERSION_NUMBER)
!endif

build_ui:
!ifneq ("$(UIBUILD)", "0")
	$(PERL) $(DE_EPAGES)/Presentation/Scripts/buildUi.pl -storetype $(STORE_TYPE) -version $(EPAGES_VERSION_NUMBER)
!endif

synchronize: makefile var\STORE var\SITE_NAME test_store
!ifndef EPAGES_IGNORE_SITE
	$(PERL) $(DE_EPAGES)/ShopConfiguration/Scripts/synccartridges.pl -storename $(STORE) -sitename $(SITE_NAME)
!endif

install_all: var\STORE set\STORE_TYPE var\STORE_TYPE var\SITE_NAME
	echo "Running $(@F) for Store $(STORE) / StoreType $(STORE_TYPE) for Cartridge $(CARTRIDGES)"
	-$(MAKE_INSTALL) uninstall
	$(MAKE) unregister
	$(MAKE_INSTALL) install
	$(MAKE) build_storetype STORE_TYPE=$(STORE_TYPE)
	$(MAKE) register
	$(MAKE) synchronize STORE=$(STORE)
	$(MAKE) cache_reset
