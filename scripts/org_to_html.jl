using Genie

function org_to_html(org_content::String)
    lines = split(org_content, "\n")
    html_lines = String[]
    in_code_block = false
    in_quote_block = false
    in_list = false
    in_ordered_list = false
    in_table = false
    table_header = false

    for line in lines
        if startswith(line, "#+BEGIN_SRC")
            push!(html_lines, "<pre><code>")
            in_code_block = true
        elseif startswith(line, "#+END_SRC")
            push!(html_lines, "</code></pre>")
            in_code_block = false
        elseif startswith(line, "#+BEGIN_QUOTE")
            push!(html_lines, "<blockquote>")
            in_quote_block = true
        elseif startswith(line, "#+END_QUOTE")
            push!(html_lines, "</blockquote>")
            in_quote_block = false
        elseif in_code_block
            push!(html_lines, escape_html(line))
        elseif in_quote_block
            push!(html_lines, line)
        elseif startswith(line, "* ")
            push!(html_lines, "<h1>" * process_inline_elements(strip(line, ['*', ' '])) * "</h1>")
        elseif startswith(line, "** ")
            push!(html_lines, "<h2>" * process_inline_elements(strip(line, ['*', ' '])) * "</h2>")
        elseif startswith(line, "*** ")
            push!(html_lines, "<h3>" * process_inline_elements(strip(line, ['*', ' '])) * "</h3>")
        elseif startswith(line, "- ")
            if !in_list
                push!(html_lines, "<ul>")
                in_list = true
            end
            push!(html_lines, "<li>" * process_inline_elements(strip(line, ['-', ' '])) * "</li>")
        elseif match(r"^\d+\.\s", line) !== nothing
            if !in_ordered_list
                push!(html_lines, "<ol>")
                in_ordered_list = true
            end
            push!(html_lines, "<li>" * process_inline_elements(replace(line, r"^\d+\.\s" => "")) * "</li>")
        elseif startswith(line, "|")
            if !in_table
                push!(html_lines, "<table>")
                in_table = true
                table_header = true
            end
            if table_header
                cells = split(strip(line, ['|', ' ']), "|")
                push!(html_lines, "<tr>" * join(["<th>" * process_inline_elements(strip(cell, [' ', '*'])) * "</th>" for cell in cells]) * "</tr>")
                table_header = false
            elseif line == "|----|----|"
                continue  # Skip the separator line
            else
                cells = split(strip(line, ['|', ' ']), "|")
                push!(html_lines, "<tr>" * join(["<td>" * process_inline_elements(strip(cell, ' ')) * "</td>" for cell in cells]) * "</tr>")
            end
        elseif strip(line) == ""
            if in_list
                push!(html_lines, "</ul>")
                in_list = false
            end
            if in_ordered_list
                push!(html_lines, "</ol>")
                in_ordered_list = false
            end
            if in_table
                push!(html_lines, "</table>")
                in_table = false
            end
            push!(html_lines, "<br>")
        else
            if in_list
                push!(html_lines, "</ul>")
                in_list = false
            end
            if in_ordered_list
                push!(html_lines, "</ol>")
                in_ordered_list = false
            end
            if in_table
                push!(html_lines, "</table>")
                in_table = false
            end
            push!(html_lines, "<p>" * process_inline_elements(line) * "</p>")
        end
    end

    # Fermer les balises ouvertes
    if in_list
        push!(html_lines, "</ul>")
    end
    if in_ordered_list
        push!(html_lines, "</ol>")
    end
    if in_table
        push!(html_lines, "</table>")
    end

    return join(html_lines, "\n")
end

function process_inline_elements(text::String)
    # Traiter les liens et les images
    text = replace(text, r"\[\[([^\]]+)\]\[([^\]]+)\]\]" => s"<a href=\"\1\">\2</a>")
    text = replace(text, r"\[\[([^\]]+)\]\]" => s"<img src=\"\1\" alt=\"\">")
    # Traiter le texte en gras et en italique
    text = replace(text, r"\*([^\*]+)\*" => s"<strong>\1</strong>")
    text = replace(text, r"/([^/]+)/" => s"<em>\1</em>")
    # Traiter le texte en code
    text = replace(text, r"~([^~]+)~" => s"<code>\1</code>")
    return text
end

function escape_html(text::String)
    replace(text, "<" => "&lt;", ">" => "&gt;", "&" => "&amp;", "\"" => "&quot;", "'" => "&#39;")
end

function convert_org_to_html(input_dir::String, output_dir::String)
    mkpath(output_dir)
    
    for (root, _, files) in walkdir(input_dir)
        for file in files
            if endswith(file, ".org")
                input_path = joinpath(root, file)
                rel_path = relpath(input_path, input_dir)
                output_path = joinpath(output_dir, replace(rel_path, ".org" => ".html"))
                
                mkpath(dirname(output_path))
                
                org_content = read(input_path, String)
                html_content = org_to_html(org_content)
                
                # Ajouter le titre dans le <head>
                title = "My Org Site"  # Vous pouvez extraire le titre ici si nécessaire
                full_html = """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>$title</title>
                    <link rel="stylesheet" href="/css/style.css">
                </head>
                <body>
                    $html_content
                </body>
                </html>
                """
                
                write(output_path, full_html)
            end
        end
    end
end

convert_org_to_html("content", "public")