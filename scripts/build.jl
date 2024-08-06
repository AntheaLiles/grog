# Ajouter le chemin du module OrgSiteGenerator
push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

using OrgSiteGenerator

# Convertir les fichiers Org en HTML
OrgSiteGenerator.convert_org_to_html("content", "public")

# Construire le site avec Genie
OrgSiteGenerator.build_site()
