#' Replay a list of evaluated results, just like you'd run them in a R
#' terminal.
#'
#' @param x result from \code{\link{evaluate}}
#' @param pic_base_name base picture name to be used
#' @author Barret Schloerke
#' @keywords internal
#' @import parser
helpr_replay <- function(x, pic_base_name) UseMethod("helpr_replay", x)

helpr_replay.list <- function(x, pic_base_name) {
  lapply(seq_along(x), function(i, base_name = pic_base_name) {
    item <- x[[i]]
    item_name <- str_c(base_name, "_", i, collapse = "")
    helpr_replay(item, item_name)
  })
}

helpr_replay.character <- function(x, pic_base_name) {
  eval_tag_output(x)
}

helpr_replay.source <- function(x, pic_base_name) {
  if (str_trim(x$src) == "") return(x$src)

  parsed <- parser::parser(text = x$src)
  highlight(parsed)
}

helpr_replay.warning <- function(x, pic_base_name) {
  strong(str_c("Warning message:\n", x$message, collapse = ""))
}

helpr_replay.message <- function(x, pic_base_name) {
  strong(gsub("\n$", "", x$message))
}

helpr_replay.error <- function(x, pic_base_name) {
  if (is.null(x$call)) {
    strong(str_c("Error: ", x$message, collapse = "\n"))    
  } else {
    call <- deparse(x$call)
    strong(str_c("Error in ", call, ": ", x$message, collapse = "\n"))    
  }
}

helpr_replay.value <- function(x, pic_base_name) {
  if (x$visible) eval_tag_output(str_c(capture.output(print(x$value)), collapse = "\n"))
}

helpr_replay.recordedplot <- function(x, pic_base_name) {  
  file_loc <- save_picture(pic_base_name, x)
  str_c("<img class=\"R_output_image\" src=\"", file_loc, "\" alt=\"", pic_base_name, "\" />", collapse = "")
}

#' Strong HTML
#'
#' @author Barret Schloerke
#' @keywords internal
strong <- function(x) {
  eval_tag_output(str_c("\n<strong>",x,"</strong>"))
}


#' Eval text using the global environment.
#' Using memoise to speedup reproducability.
#'
#' @param txt text to be evaluated
#' @author Barret Schloerke
#' @keywords internal
#' importFrom evaluate evaluate
eval_on_global <- memoise(function(txt) {
  evaluate:::evaluate(txt, globalenv())
})

#' Evaluate text and return the corresponding text output and source.
#'
#' @param txt text to be evaluated
#' @param pic_base_name base name for the picture files
#' @author Barret Schloerke
#' @keywords internal
evaluate_text <- function(txt, pic_base_name) {
  if (!has_text(txt)) return("")

  evaluated <- eval_on_global(txt)
  replayed <- helpr_replay(evaluated, pic_base_name)
  str_c(as.character(unlist(replayed)), collapse = "\n")
}

#' Tag the output text with correct css class
#' 
#' @author Barret Schloerke
#' @keywords internal
eval_tag_output <- function(x) {
  str_c("<pre class=\"R_output\">", x, "</pre>")
}

#' Evaluate demo in the R console.
#'
#' @param package package in question
#' @param dem demo in question
#' @author Barret Schloerke
#' @keywords internal
exec_pkg_demo <- function(package, dem) {
  demo(dem, character = TRUE, package = package, ask = TRUE)
}

