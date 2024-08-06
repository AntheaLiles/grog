using Genie

function build_site()
    # Remove the OrgSite directory if it exists
    if isdir("OrgSite")
        rm("OrgSite", recursive=true)
    end

    # Create the OrgSite directory
    mkdir("OrgSite")

    cd("OrgSite") do
        Genie.Generator.newapp("OrgSite", autostart = false)
        create_routes()
        create_layout()
    end

    # Ensure the public directory exists
    mkpath("public")

    # Create index.html in the public directory
    write("public/index.html", """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mon Site Org</title>
        <link rel="stylesheet" href="/css/style.css">
    </head>
    <body>
        <div id="app"></div>
        <script type="module" src="/src/main.js"></script>
    </body>
    </html>
    """)

    # Ensure the CSS directory exists and create a basic style.css
    mkpath("public/css")
    write("public/css/style.css", """
    body {
        font-family: Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    """)

    # Ensure the src directory exists and create a basic main.js
    mkpath("public/src")
    write("public/src/main.js", """
    console.log('Hello, world!');
    """)
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
    # Ensure the layouts directory exists
    mkpath("layouts")

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