using Genie

function build_site()
    # Create the OrgSite directory if it doesn't exist
    isdir("OrgSite") || mkdir("OrgSite")

    cd("OrgSite") do
        Genie.Generator.newapp("OrgSite", autostart = false)
        create_routes()
        create_layout()
        Genie.Generator.write_static_files()
    end
end

function create_routes()
    for (root, _, files) in walkdir("../public")
        for file in files
            if endswith(file, ".html")
                route_path = "/" * replace(relpath(joinpath(root, file), "../public"), ".html" => "")
                route(route_path) do
                    html(read(joinpath(root, file), String))
                end
            end
        end
    end
end

function create_layout()
    layout = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{{PAGE_TITLE}}</title>
        <link rel="stylesheet" href="/css/style.css">
    </head>
    <body>
        <header>
            <h1>Mon Site Org</h1>
            <nav>
                <a href="/">Accueil</a>
                <a href="/about">À propos</a>
                <a href="/blog">Blog</a>
            </nav>
        </header>
        
        <main>
            {{yield}}
        </main>
        
        <footer>
            <p>&copy; 2024 Mon Site Org</p>
        </footer>
    </body>
    </html>
    """
    
    write("layouts/app.jl.html", layout)
end

build_site()
