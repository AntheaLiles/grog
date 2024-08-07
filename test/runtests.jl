using Test
using OrgSiteGenerator

@testset "OrgSiteGenerator Tests" begin
    # Test de conversion des titres
    @test occursin("<h1>Titre 1</h1>", org_to_html("* Titre 1"))
    @test occursin("<h2>Titre 2</h2>", org_to_html("** Titre 2"))
    @test occursin("<h3>Titre 3</h3>", org_to_html("*** Titre 3"))

    # Test de conversion des paragraphes
    @test occursin("<p>Ceci est un paragraphe.</p>", org_to_html("Ceci est un paragraphe."))

    # Test de conversion du texte en gras et en italique
    @test occursin("<strong>gras</strong>", org_to_html("*gras*"))
    @test occursin("<em>italique</em>", org_to_html("/italique/"))

    # Test de conversion des listes
    @test occursin("<ul><li>Item 1</li><li>Item 2</li></ul>", org_to_html("- Item 1\n- Item 2"))
    @test occursin("<ol><li>Premier</li><li>Deuxième</li></ol>", org_to_html("1. Premier\n2. Deuxième"))

    # Test de conversion des liens
    @test occursin("<a href=\"https://example.com\">lien</a>", org_to_html("[[https://example.com][lien]]"))

    # Test de conversion des images
    @test occursin("<img src=\"image.jpg\" alt=\"\">", org_to_html("[[image.jpg]]"))

    # Test de conversion des citations
    @test occursin("<blockquote>Citation</blockquote>", org_to_html("#+BEGIN_QUOTE\nCitation\n#+END_QUOTE"))

    # Test de conversion du code en ligne
    @test occursin("<code>code</code>", org_to_html("~code~"))

    # Test de conversion des blocs de code
    @test occursin("<pre><code>", org_to_html("#+BEGIN_SRC\ncode\n#+END_SRC"))

    # Test de conversion des tableaux
    table_org = """
    | *Header 1* | *Header 2* |
    |------------|------------|
    | Cell 1     | Cell 2     |
    """
    table_html = org_to_html(table_org)
    @test occursin("<table>", table_html)
    @test occursin("<th>Header 1</th>", table_html)
    @test occursin("<td>Cell 1</td>", table_html)
end

@testset "File Conversion" begin
    test_input = mktempdir()
    test_output = mktempdir()

    # Créer une structure de fichiers de test
    mkdir(joinpath(test_input, "blog"))
    write(joinpath(test_input, "index.org"), """
    * Accueil
    Bienvenue sur mon site.
    ** Sous-titre
    Ceci est un paragraphe.
    - Liste item 1
    - Liste item 2
    """)
    write(joinpath(test_input, "blog", "post1.org"), """
    * Premier article
    Contenu du premier article
    #+BEGIN_SRC julia
    println("Hello, World!")
    #+END_SRC
    | *Colonne 1* | *Colonne 2* |
    |-------------|-------------|
    | Valeur 1    | Valeur 2    |
    """)

    # Exécuter la conversion
    convert_org_to_html(test_input, test_output)

    # Vérifier que les fichiers HTML ont été créés
    @test isfile(joinpath(test_output, "index.html"))
    @test isfile(joinpath(test_output, "blog", "post1.html"))

    # Vérifier le contenu des fichiers HTML
    index_content = read(joinpath(test_output, "index.html"), String)
    @test occursin("<h1>Accueil</h1>", index_content)
    @test occursin("<h2>Sous-titre</h2>", index_content)
    @test occursin("<ul>", index_content)
    @test occursin("<li>Liste item 1</li>", index_content)

    post_content = read(joinpath(test_output, "blog", "post1.html"), String)
    @test occursin("<h1>Premier article</h1>", post_content)
    @test occursin("<pre><code>", post_content)
    @test occursin("<table>", post_content)
    @test occursin("<th>Colonne 1</th>", post_content)
    @test occursin("<td>Valeur 1</td>", post_content)
end
