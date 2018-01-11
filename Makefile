
DIR_OUTPUT= www
HTML_FILE= index.html \
	login.html

JS_FILE= config.js \
	dashboard.js

ASSETS_FOLDER= assets

SPINALADMIN_FOLDER=SpinalAdmin
SPINALADMIN_FILES = $(SPINALADMIN_FOLDER)/admin.models.js \
	$(SPINALADMIN_FOLDER)/admin.views.js \
	$(SPINALADMIN_FOLDER)/admin.stylesheets.css 

all:
	@echo "compiling admin..."
	@(cd SpinalAdmin && $(MAKE) --no-print-directory)

clean:
	@(cd SpinalAdmin && $(MAKE) --no-print-directory clean)

init:
	@mkdir -p $(DIR_OUTPUT)
	@cp -r $(HTML_FILE) $(JS_FILE) $(DIR_OUTPUT)
	@cp -r $(ASSETS_FOLDER) $(DIR_OUTPUT)
	@mkdir -p $(DIR_OUTPUT)/$(SPINALADMIN_FOLDER)
	@cp $(SPINALADMIN_FILES) $(DIR_OUTPUT)/$(SPINALADMIN_FOLDER)
	@echo "init done"
