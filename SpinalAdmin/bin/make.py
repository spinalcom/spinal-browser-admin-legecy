#!/usr/bin/python2

from concat_js import *

models = []
views = []
stylesheets = []

for p in os.listdir( "modules" ):
    for m in os.listdir("modules/" + p):
        if m == "models":
            models.append("gen/" + m + "/" + p + ".js")
            concat_js( "modules/" + p + "/" + m, "gen/" + m + "/" + p + ".js", "gen/stylesheets/" + p + ".css" )

        elif m == "views":
            views.append("gen/" + m + "/" + p + ".js")
            concat_js( "modules/" + p + "/" + m, "gen/" + m + "/" + p + ".js", "gen/stylesheets/" + p + ".css" )

        elif m == "stylesheets":
            stylesheets.append("gen/" + m + "/" + p + ".css")
            concat_js( "modules/" + p + "/" + m, "gen/" + m + "/" + p + ".js", "gen/stylesheets/" + p + ".css" )

exec_cmd_silent( "echo > admin.models.js " )
exec_cmd_silent( "echo > admin.views.js " )
exec_cmd_silent( "echo > admin.stylesheets.css " )

print ("\033[0;35mConcat file : admin.models.js\033[m");
for m in sorted(models):
    exec_cmd_silent( "cat admin.models.js " + m + " > admin.models_tmp.js" )
    exec_cmd_silent( "mv admin.models_tmp.js admin.models.js" )
print ("\033[0;35mConcat file : admin.views.js\033[m");
for v in sorted(views):
    exec_cmd_silent( "cat admin.views.js " + v + " > admin.views_tmp.js" )
    exec_cmd_silent( "mv admin.views_tmp.js admin.views.js" )
print ("\033[0;35mConcat file : admin.stylesheets.css\033[m");
for s in sorted(stylesheets):
    exec_cmd_silent( "cat admin.stylesheets.css " + s + " > admin.stylesheets_tmp.css" )
    exec_cmd_silent( "mv admin.stylesheets_tmp.css admin.stylesheets.css" )
