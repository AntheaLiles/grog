include("org_to_html.jl")
include("build_site.jl")

# Convertir les fichiers Org en HTML
convert_org_to_html("content", "public")

# Construire le site avec Genie
build_site()