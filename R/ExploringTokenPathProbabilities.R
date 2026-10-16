####################################################################################################################
# title: 	ExploringTokenPathProbabilities
# author: 	Dr. Andreas Fischer
# date: 	16.10.2026
# source: 	https://github.com/AndreasFischer1985/code-snippets/blob/master/R/ExploringTokenPathProbabilities.R
####################################################################################################################


# nur für's Archiv: der Weg über den completions-Endpunkt
#---------------------------------------------------------

library(httr)
library(jsonlite)

get_next_token_completion <- function(user_input, assistant_output = "", base_url = "http://localhost:1234/v1") {  
  # Gemma 4 Completions-Format zusammenbauen, aktuell "<|turn>user\nTest<turn|>\n<|turn>model\n" statt "<|turn>user\nTest<|turn>model\n")
  prompt_text <- paste0( "<|turn>user\n", user_input, "<turn|>\n<|turn>model\n", assistant_output )  
  body <- list(
    prompt = prompt_text,
    max_tokens = 1,
    temperature = 0.0, 
    logprobs = 5,      
    stop = list("<|turn>", "<turn|>", "<|endoftext|>")
  )  
  response <- POST(
    url = paste0(base_url, "/completions"),
    body = body,
    encode = "json",
    add_headers(`Content-Type` = "application/json")
  )  
  if (status_code(response) != 200) {
    stop("API-Fehler: ", content(response, "text", encoding = "UTF-8"))
  }  
  res_content <- content(response, "parsed", simplifyVector = FALSE)
  choice <- res_content$choices[[1]]  
  # Daten extrahieren
  chosen_token <- choice$text
  logprobs_obj <- choice$logprobs  
  token_logprob <- if (!is.null(logprobs_obj$token_logprobs)) logprobs_obj$token_logprobs[[1]] else NA  
  # Top Logprobs abrufen (benannte Liste: Token -> Logprob)
  top_logprobs_list <- list()
  if (!is.null(logprobs_obj$top_logprobs) && length(logprobs_obj$top_logprobs) > 0) {
    top_logprobs_list <- logprobs_obj$top_logprobs[[1]]
  }  
  return(list(
    token = chosen_token,
    logprob = token_logprob,
    top_logprobs = top_logprobs_list
  ))
}


# Relevant für explore_token_paths & explore_token_tree
#-------------------------------------------------------

library(httr)
library(jsonlite)

get_next_token <- function(user_input, assistant_output = "", base_url = "http://localhost:1234/v1",verbose=T) {
  # Messages-Array für den Chat-Endpoint aufbauen
  messages_list <- list(
    list(role = "user", content = user_input)
  )
  # Wenn ein Assistant-Prefix vorgegeben wird, als Assistant-Nachricht anhängen (Prefill)
  if (nzchar(assistant_output)) {
    messages_list[[2]] <- list(role = "assistant", content = assistant_output)
  }  
  if(verbose==T) print(messages_list)
  body <- list(
    model = "local-model",
    messages = messages_list,
    max_tokens = 1,
    temperature = 0.0,
    logprobs = TRUE,
    top_logprobs = 5
  )
  response <- POST(
    url = paste0(base_url, "/chat/completions"),
    body = body,
    encode = "json",
    add_headers(`Content-Type` = "application/json")
  )  
  if (status_code(response) != 200) {
    stop("API-Fehler: ", content(response, "text", encoding = "UTF-8"))
  }
  res_content <- content(response, "parsed", simplifyVector = FALSE)
  choice <- res_content$choices[[1]]
  chosen_token <- NULL
  token_logprob <- NA
  top_logprobs_list <- list()
  # OpenAI-Standardstruktur für Logprobs auslesen
  if (!is.null(choice$logprobs) && !is.null(choice$logprobs$content) && length(choice$logprobs$content) > 0) {
    logprob_entry <- choice$logprobs$content[[1]]
    chosen_token <- logprob_entry$token
    token_logprob <- logprob_entry$logprob
    
    if (!is.null(logprob_entry$top_logprobs)) {
      for (tp in logprob_entry$top_logprobs) {
        top_logprobs_list[[tp$token]] <- tp$logprob
      }
    }
  } else {
    chosen_token <- choice$message$content
  }  
  return(list(
    token = chosen_token,
    logprob = token_logprob,
    top_logprobs = top_logprobs_list
  ))
}


# Alle token-pfade von tokens mit logprob>threshold bis zu maximal max_length
#-----------------------------------------------------------------------------

explore_token_paths <- function(user_input, initial_assistant = "", threshold = -2.0, max_length = 3, base_url = "http://localhost:1234/v1") {  
  results <- data.frame(text = character(), cumulative_logprob = numeric(), stringsAsFactors = FALSE)  
  # Rekursive Hilfsfunktion (DFS - Depth-First Search)
  recurse <- function(current_assistant, current_depth, current_logprob) {    
  # Abbruchbedingung: Maximale Länge erreicht
    if (current_depth > max_length) {
      results <<- rbind(results, data.frame(
        text = current_assistant, 
        cumulative_logprob = current_logprob, 
        stringsAsFactors = FALSE
      ))
      return()
    }    
    # Nächste Tokens und Top-Logprobs abrufen
    res <- tryCatch({
      get_next_token(user_input, current_assistant, base_url)
    }, error = function(e) {
      message("Fehler bei Token-Abruf: ", e$message)
      return(NULL)
    })    
    if (is.null(res) || length(res$top_logprobs) == 0) {
      results <<- rbind(results, data.frame(
        text = current_assistant, 
        cumulative_logprob = current_logprob, 
        stringsAsFactors = FALSE
      ))
      return()
    }    
    # Filtern nach Schwellenwert
    top_lp <- res$top_logprobs
    tokens_to_explore <- list()    
    for (tok_name in names(top_lp)) {
      lp <- top_lp[[tok_name]]
      if (!is.null(lp) && !is.na(lp) && lp >= threshold) {
        tokens_to_explore[[tok_name]] <- lp
      }
    }    
    # Wenn kein Token den Schwellenwert erreicht, Ast beenden
    if (length(tokens_to_explore) == 0) {
      results <<- rbind(results, data.frame(
        text = current_assistant, 
        cumulative_logprob = current_logprob, 
        stringsAsFactors = FALSE
      ))
      return()
    }    
    # Rekursion für jedes valide Token
    for (tok_name in names(tokens_to_explore)) {
      lp <- tokens_to_explore[[tok_name]]
      new_assistant <- paste0(current_assistant, tok_name)
      new_logprob <- current_logprob + lp # Logprobs werden bei Sequenzen addiert
      
      recurse(new_assistant, current_depth + 1, new_logprob)
    }
  }  
  # Start der Suche
  recurse(initial_assistant, 1, 0.0)  
  # Kumulierte Wahrscheinlichkeit berechnen (exp von cumulative_logprob)
  if (nrow(results) > 0) {
    results$probability <- exp(results$cumulative_logprob)
    # Sortieren nach bester Wahrscheinlichkeit (höchster logprob) absteigend
    results <- results[order(results$cumulative_logprob, decreasing = TRUE), ]
    rownames(results) <- NULL
  }  
  return(results)
}


# Alle token-pfade von tokens mit logprob>threshold bis zu maximal max_length als Tree
#---------------------------------------------------------------------------------------

library(data.tree)
library(collapsibleTree)
library(DiagrammeR)

explore_token_tree <- function(user_input, initial_assistant = "", threshold = -8, max_length = 2, base_url = "http://localhost:1234/v1") {  
  root <- Node$new("", text = initial_assistant, logprob = 0, cumulative_logprob = 0, step_probability = 1.0, probability = 1.0)  
  recurse <- function(node, current_depth) {
    if (current_depth > max_length) return()    
    res <- tryCatch({
      get_next_token(user_input, node$text, base_url)
    }, error = function(e) {
      message("Fehler bei Token-Abruf: ", e$message)
      return(NULL)
    })    
    if (is.null(res) || length(res$top_logprobs) == 0) return()    
    top_lp <- res$top_logprobs
    for (tok_name in names(top_lp)) {
      lp <- top_lp[[tok_name]]
      if (!is.null(lp) && !is.na(lp) && lp >= threshold) {
        new_text <- paste0(node$text, tok_name)
        new_cum_logprob <- node$cumulative_logprob + lp        
        step_prob <- exp(lp)
        cum_prob <- exp(new_cum_logprob)        
        # Säubern für Graphviz (EINZEILIG, keine echten Zeilenumbrüche im Namen!)
        safe_tok <- tok_name
        safe_tok <- gsub("\n", "\\n", safe_tok) 
        safe_tok <- gsub("\"", "'", safe_tok)                   
        node_label <- sprintf("'%s' (p=%.3f)", safe_tok, step_prob)        
        child <- node$AddChild(
          node_label, 
          text = new_text, 
          token = tok_name,
          logprob = round(lp, 2),
          step_probability = round(step_prob, 4),
          cumulative_logprob = round(new_cum_logprob, 2),
          probability = round(cum_prob, 4)
        )        
        recurse(child, current_depth + 1)
      }
    }
  }  
  recurse(root, 1)
  return(root)
}


# Rekonstruktion aller Pfade als Fließtext aus Tree
#---------------------------------------------------------------------------------------

library(data.tree)

get_complete_paths <- function(node) {
  traverse_tree <- function(current_node, current_path_raw, current_path_clean, current_prob) {
    
    node_name <- current_node$name
    step_p <- if (!is.null(current_node$step_probability)) current_node$step_probability else 1.0
    
    # 1. "(p=...)" am Ende entfernen
    clean_token <- sub(" \\(p=.*\\)$", "", node_name)
    
    # 2. Äußere Anführungszeichen des Tokens entfernen, falls vorhanden
    if (nchar(clean_token) >= 2 && substr(clean_token, 1, 1) == "'" && substr(clean_token, nchar(clean_token), nchar(clean_token)) == "'") {
      clean_token <- substr(clean_token, 2, nchar(clean_token) - 1)
    }
    
    if (!current_node$isRoot && nzchar(node_name)) {
      current_path_raw <- c(current_path_raw, node_name)       # Mit Wahrscheinlichkeit für den Pfad
      current_path_clean <- c(current_path_clean, clean_token) # Reines Token für den Fließtext
      current_prob <- current_prob * step_p
    }
    
    if (current_node$isLeaf) {
      path_str <- paste(current_path_raw, collapse = " -> ")
      text_str <- paste(current_path_clean, collapse = "")
      
      return(data.frame(
        Pfad = path_str,
        Fließtext = text_str,
        Kumulierte_Wahrscheinlichkeit = current_prob,
        stringsAsFactors = FALSE
      ))
    }
    
    res_list <- lapply(current_node$children, function(child) {
      traverse_tree(child, current_path_raw, current_path_clean, current_prob)
    })
    
    return(do.call(rbind, res_list))
  }
  
  traverse_tree(node, character(0), character(0), 1.0)
}


# Statistik aus Tree (und validen Kategorien)
#---------------------------------------------

library(dplyr)
library(stringr)
library(data.tree)

analyze_token_categorization <- function(token_tree, valid_categories) {  
  # Hilfsfunktion zur strengen Prüfung, ob ein Treffer ein gültiges, isoliertes Token ist
  validate_match <- function(text, start, end) {
    n <- nchar(text)
    # 1. Vorheriges Zeichen prüfen
    if (start > 1) {
      prev_char <- substr(text, start - 1, start - 1)
      # Ungültig, wenn direkt von einem Buchstaben oder einer Ziffer umgeben (z.B. "21" oder "a1")
      if (grepl("[0-9a-zA-Z]", prev_char)) return(FALSE)
      # Ungültig, wenn Teil einer Dezimalzahl als Nachkommastelle (z.B. "0.1" oder "0,1")
      if (prev_char %in% c(".", ",") && start > 2) {
        prev_prev_char <- substr(text, start - 2, start - 2)
        if (grepl("[0-9]", prev_prev_char)) return(FALSE)
      }
    }
    # 2. Folgendes Zeichen prüfen
    if (end < n) {
      next_char <- substr(text, end + 1, end + 1)
      # Ungültig, wenn direkt von einem Buchstaben oder einer Ziffer gefolgt (z.B. "12" oder "1a")
      if (grepl("[0-9a-zA-Z]", next_char)) return(FALSE)
      # Ungültig, wenn gefolgt von Dezimaltrenner und Ziffer (z.B. "1.0", "1.000", "1,5")
      if (next_char %in% c(".", ",") && end < n - 1) {
        next_next_char <- substr(text, end + 2, end + 2)
        if (grepl("[0-9]", next_next_char)) return(FALSE)
      }
    }    
    return(TRUE)
  }
  # 1. Falls data.tree Node-Objekt, Text in korrekter Reihenfolge (Root-to-Leaf) aufbauen
  if (inherits(token_tree, "Node")) {
    tree_df <- ToDataFrameTable(
      token_tree, 
      token            = function(x) x$token,
      logprob          = function(x) x$logprob,
      step_probability = function(x) x$step_probability,
      probability      = function(x) x$probability,
      text             = function(x) {
        tokens <- c()
        curr <- x
        while(!is.null(curr)) {
          tokens <- c(curr$token, tokens) # Voranstellen für korrekte Reihenfolge
          curr <- curr$parent
        }
        tokens <- tokens[!sapply(tokens, is.null)]
        paste0(unlist(tokens), collapse = "")
      }
    )
  } else {
    tree_df <- token_tree
    if (!"text" %in% names(tree_df) && "pathString" %in% names(tree_df)) {
      tree_df$text <- tree_df$pathString
    }
  }
  valid_cats <- as.character(valid_categories)
  # 2. Zuordnung mit strikter Kontextprüfung pro Pfad/Antwort
  tree_df <- tree_df %>%
    mutate(
      matched_category = sapply(text, function(t) {
        for (cat in valid_cats) {
          locs <- str_locate_all(t, fixed(cat))[[1]]
          if (nrow(locs) > 0) {
            for (i in 1:nrow(locs)) {
              if (validate_match(t, locs[i, 1], locs[i, 2])) {
                return(cat) # Erste valide Kategorie im Pfad zurückgeben
              }
            }
          }
        }
        return(NA_character_)
      }),
      is_valid = !is.na(matched_category)
    )
  # 3. Aggregation pro gültiger Kategorie
  cat_summary <- tree_df %>%
    filter(is_valid) %>%
    group_by(matched_category) %>%
    summarise(
      total_probability = sum(probability, na.rm = TRUE),
      n_variants = n(),
      variants = list(tibble(text = text, probability = probability))
    ) %>%
    arrange(desc(total_probability))
  # Wahrscheinlichste und zweitwahrscheinlichste Kategorie ermitteln
  most_likely_cat  <- if(nrow(cat_summary) > 0) cat_summary$matched_category[1] else NA_character_
  most_likely_prob <- if(nrow(cat_summary) > 0) cat_summary$total_probability[1] else 0
  second_likely_cat  <- if(nrow(cat_summary) > 1) cat_summary$matched_category[2] else NA_character_
  second_likely_prob <- if(nrow(cat_summary) > 1) cat_summary$total_probability[2] else 0
  prob_diff <- most_likely_prob - second_likely_prob
  # 4. Analyse ungültiger Antworten
  invalid_summary <- tree_df %>% filter(!is_valid)
  invalid_total_prob <- sum(invalid_summary$probability, na.rm = TRUE)
  detailed_categories <- setNames(cat_summary$variants, cat_summary$matched_category)
  # 5. Ergebnis zurückgeben
  return(list(
    most_likely = list(
      category = most_likely_cat, 
      probability = most_likely_prob
    ),
    second_likely = list(
      category = second_likely_cat, 
      probability = second_likely_prob,
      difference_to_first = prob_diff
    ),
    invalid_responses = list(
      total_probability = invalid_total_prob,
      count = nrow(invalid_summary)
    ),
    category_summary = cat_summary %>% select(matched_category, n_variants, total_probability),
    variants_per_category = detailed_categories
  ))
}


# Formatierung der Statistiken
#-------------------------------

format_categorization_text <- function(analysis_result) {
  ml <- analysis_result$most_likely
  sl <- analysis_result$second_likely
  inv <- analysis_result$invalid_responses
  
  # Fall: Keine gültige Kategorie gefunden
  if (is.na(ml$category)) {
    inv_pct <- sprintf("%.2f%%", inv$total_probability * 100)
    return(paste0(
      "Die Analyse ergab **keine gültige Kategorienzuordnung**. ",
      "Alle ", inv$count, " untersuchten Pfade im Token-Baum führten zu ungültigen Antworten ",
      "(Gesamtwahrscheinlichkeit der Fehlerausgabe: ", inv_pct, ")."
    ))
  }
  
  # Prozentwerte formatieren
  ml_pct <- sprintf("%.1f%%", ml$probability * 100)
  
  # Basissatz für die wahrscheinlichste Kategorie
  text <- paste0(
    "Die wahrscheinlichste Kategorie ist **", ml$category, "** ",
    "mit einer kumulierten Wahrscheinlichkeit von **", ml_pct, "**."
  )
  
  # Einbindung der zweitwahrscheinlichsten Kategorie (falls vorhanden)
  if (!is.na(sl$category)) {
    sl_pct <- sprintf("%.1f%%", sl$probability * 100)
    diff_pct <- sprintf("%.1f%%", sl$difference_to_first * 100)
    
    # Einschätzung der Eindeutigkeit basierend auf der Differenz
    eindeutigkeit <- if (sl$difference_to_first > 0.8) {
      "äußerst eindeutig"
    } else if (sl$difference_to_first > 0.3) {
      "sehr klar"
    } else if (sl$difference_to_first > 0.05) {
      "überwiegend wahrscheinlich, lässt jedoch Raum für Interpretationen"
    } else {
      "ein sehr knapper Grenzfall zwischen den Kategorien"
    }
    
    text <- paste0(
      text, " Die zweitwahrscheinlichste Option ist Kategorie **", sl$category, "** ",
      "mit ", sl_pct, ". Die Differenz beträgt ", diff_pct, ", womit die Entscheidung ", eindeutigkeit, " ist."
    )
  } else {
    text <- paste0(text, " Es wurden keine nennenswerten alternativen Kategorien im Baum gefunden, wodurch das Modell extrem sicher agiert.")
  }
  
  # Hinweis auf ungültige Antworten / Halluzinationen
  if (inv$total_probability > 0.001) {
    inv_pct <- sprintf("%.2f%%", inv$total_probability * 100)
    text <- paste0(
      text, " Achtung: Ungültige Antworten oder Formatabweichungen ",
      "machen insgesamt ", inv_pct, " der Modell-Wahrscheinlichkeit aus (verteilt auf ", inv$count, " Pfad-Varianten)."
    )
  }
  
  return(text)
}


############################################
# Anwendungsbeispiele:
# bsp: Veranschaulichung für Prompt "Test"
# cla: Exemplarische Textklassifikation
#############################################


# Token paths
#--------------

# Beispiel-Aufruf:
ergebnisse_bsp <- explore_token_paths(
  user_input = "Test",
  initial_assistant = "",       # Vorgabe, ab der weitergeneriert wird
  threshold = -3,               # Nur Tokens mit Logprob >= x berücksichtigen
  max_length = 11               # x Tokens tief weitersuchen
)
# Ergebnisse anzeigen
print(ergebnisse_bsp)

# Anwendung zur Kategorienbildung:
ergebnisse_cla <- explore_token_paths(
  user_input ='Du bist ein wissenschaftlicher Assistent für qualitative Inhaltsanalysen nach Fischer (2025).
Kontext der Analyse: Zu bewerten sind Aussagen, die im Rahmen eines Interviews zur KI-basierten Inhaltsanalyse gemacht wurden.
Text:\n"Befragte Person: Ich bin wirklich begeistert. Die strukturierte Extraktion mit MyQDA spart uns enorm viel Zeit bei der Aufbereitung des Korpus, und die Nachvollziehbarkeit der Kodierungen ist hervorragend."\n\nAufgabe: Ordne diese Äußerungen deduktiv je einer der folgenden Kategorien zu: (1) positive Äußerung, (2) neutrale Äußerung, (3) negative Äußerung.\nBelege deine Zuordnung dabei mit passenden Textstellen.\nFormuliere deine Antwort als JSON-Liste im folgenden Format:
[
  {
    "code": "Nummer der passende Kategorie",
    "description": "Code-Label",
    "textstellen": ["Exaktes wörtliches Zitat 1", "Exaktes wörtliches Zitat 2"]
  }
]',
  initial_assistant = '[\n  {\n    "code": ',  	# Vorgabe, ab der weitergeneriert wird
  threshold = -8,             			# Nur Tokens mit Logprob >= x berücksichtigen
  max_length = 2                		# x Tokens tief weitersuchen
)
# Ergebnisse anzeigen
print(ergebnisse_cla)

#                    text cumulative_logprob  probability
#1 [\n  {\n    "code": 1,      -9.253686e-04 9.990751e-01
#2 [\n  {\n    "code": 3,      -7.543771e+00 5.293975e-04
#3 [\n  {\n    "code": 2,      -7.873997e+00 3.805103e-04
#4 [\n  {\n    "code": 20      -1.330490e+01 1.666309e-06
#5 [\n  {\n    "code": 30      -1.332101e+01 1.639680e-06
#6 [\n  {\n    "code": 31      -1.475633e+01 3.903095e-07
#7 [\n  {\n    "code": 2.      -1.520545e+01 2.490907e-07
#8 [\n  {\n    "code": 25      -1.534617e+01 2.163923e-07
#9 [\n  {\n    "code": 21      -1.560911e+01 1.663602e-07


# Token-tree
#------------
  
# Beispiel-Aufruf zwecks Visualisierung
token_tree_bsp <- explore_token_tree(
  user_input = "Test",
  initial_assistant = "",
  threshold = -3,
  max_length = 10
)
print(token_tree_bsp, "token", "logprob", "step_probability", "probability", limit = 30)
  
ct=collapsibleTree(
  token_tree_bsp, 
  attribute = "step_probability", # Färbt/skaliert nach Übergangs-Wahrscheinlichkeit
  rootName = "Generierungs-Start",
  tooltip = TRUE # ,collapsed = F
)

library(htmlwidgets)
saveWidget(ct, file = "collapsibleTree.html", selfcontained = FALSE)
saveWidget(ct, file = "collapsibleTree.html", selfcontained = TRUE) # Speichern als eigenständige Datei (self-contained)
saveRDS(token_tree_bsp,"token_tree_bsp.rds")


token_tree_cla <- explore_token_tree(
  user_input ='Du bist ein wissenschaftlicher Assistent für qualitative Inhaltsanalysen nach Fischer (2025).
Kontext der Analyse: Zu bewerten sind Aussagen, die im Rahmen eines Interviews zur KI-basierten Inhaltsanalyse gemacht wurden.
Text:\n"Befragte Person: Ich bin wirklich begeistert. Die strukturierte Extraktion mit MyQDA spart uns enorm viel Zeit bei der Aufbereitung des Korpus, und die Nachvollziehbarkeit der Kodierungen ist hervorragend."\n\nAufgabe: Ordne diese Äußerungen deduktiv je einer der folgenden Kategorien zu: (1) positive Äußerung, (2) neutrale Äußerung, (3) negative Äußerung.\nBelege deine Zuordnung dabei mit passenden Textstellen.\nFormuliere deine Antwort als JSON-Liste im folgenden Format:
[
  {
    "code": "Nummer der passende Kategorie",
    "description": "Code-Label",
    "textstellen": ["Exaktes wörtliches Zitat 1", "Exaktes wörtliches Zitat 2"]
  }
]',
  initial_assistant = '[\n  {\n    "code": ',  	# Vorgabe, ab der weitergeneriert wird
  threshold = -8,             			# Nur Tokens mit Logprob >= x berücksichtigen
  max_length = 2                		# x Tokens tief weitersuchen
)

# Baum in der Konsole ausgeben (zeigt Token, Logprob und kumulierte Wahrscheinlichkeit)
print(token_tree_cla, "token", "logprob", "step_probability", "probability", limit = 30)

#> print(token_tree_cla, "token", "logprob", "step_probability", "probability", 
  limit = 30)
#               levelName token logprob step_probability probability
#1                                 0.00           1.0000      1.0000
#2   ¦--'1' (p=0.999)         1    0.00           0.9991      0.9991
#3   ¦   °--',' (p=1.000)     ,    0.00           1.0000      1.0000
#4   ¦--'3' (p=0.001)         3   -7.53           0.0005      0.0005
#5   ¦   ¦--',' (p=0.995)     ,    0.00           0.9954      0.0005
#6   ¦   ¦--'0' (p=0.003)     0   -5.78           0.0031      0.0000
#7   ¦   ¦--'1' (p=0.001)     1   -7.22           0.0007      0.0000
#8   ¦   ¦--'2' (p=0.000)     2   -8.49           0.0002      0.0000
#9   ¦   °--'.' (p=0.000)     .   -8.49           0.0002      0.0000
#10  °--'2' (p=0.000)         2   -7.86           0.0004      0.0004
#11      ¦--',' (p=0.994)     ,   -0.01           0.9936      0.0004
#12      ¦--'0' (p=0.004)     0   -5.44           0.0044      0.0000
#13      ¦--'.' (p=0.001)     .   -7.34           0.0007      0.0000
#14      ¦--'5' (p=0.001)     5   -7.48           0.0006      0.0000
#15      °--'1' (p=0.000)     1   -7.74           0.0004      0.0000

ctCla=collapsibleTree(
  token_tree_cla, 
  attribute = "step_probability", # Färbt/skaliert nach Übergangs-Wahrscheinlichkeit
  rootName = "Generierungs-Start",
  tooltip = TRUE,collapsed = F)

path="C:/Users/fischer.andreas/Documents/WIP/KIServer/KI-Analysen/Inhaltsanalyse_0_Meta/ResponsesAPI-Test"
setwd(path)

saveRDS(token_tree_cla,"token_tree_cla.rds")
save.image("workspace.RData")

library(htmlwidgets)
# Speichern als eigenständige Datei (self-contained)
#saveWidget(ctCla, file = "collapsibleTree_cla.html", selfcontained = TRUE)
saveWidget(ctCla, file = "collapsibleTree_cla.html", selfcontained = FALSE)


# Pfade
#--------

alle_pfade_cla <- get_complete_paths(token_tree_cla)
x=alle_pfade_cla
x$Pfad[1]
x$Fließtext[1]
x$Kumulierte_Wahrscheinlichkeit[1]
d=data.frame(x$Fließtext,x$Kumulierte_Wahrscheinlichkeit)
head(d[order(d[,2],decreasing=T),])

#> head(d[order(d[,2],decreasing=T),])
#  x.Fließtext x.Kumulierte_Wahrscheinlichkeit
#1          1,                      0.99910000
#2          3,                      0.00049770
#7          2,                      0.00039744
#8          20                      0.00000176
#3          30                      0.00000155
#4          31                      0.00000035


# Statistik
#------------

a1=analyze_token_categorization(token_tree_cla,c(1,2,3))
a2=analyze_token_categorization(token_tree,c(1,2,3))

f1=print(format_categorization_text(a1))
f2=print(format_categorization_text(a2))

