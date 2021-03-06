#' Read URL.
#' Retrieve the text from a URL
#' 
#' @param url_string url to explore
#' @return plain text from that url
#' @author Barret Schloerke
#' @keywords internal
read_url <- function(url_string) {
  
  url_string <- str_replace_all(url_string, "mmx-dns", "mmxMINUSdns")
  url_string <- str_replace_all(url_string, "-", "")
  url_string <- str_replace_all(url_string, "mmxMINUSdns", "mmx-dns")
  url <- URLencode(url_string)
  url_connect <- base::url(url)
  on.exit(close(url_connect))
  output <- suppressWarnings(str_c(readLines(url_connect), collapse = ""))
  output
}

#' URL with JSON result to list.
#'
#' @param url_string url that contains a JSON output to be turned into a list
#' @author Barret Schloerke
#' @keywords internal
urlJSON_to_list <- function(url_string) {
  fromJSON(read_url(url_string))
}

#' Send commit command to Solr
#' Send a commit command to Solr to finalized any submissions
#'
#' @author Barret Schloerke
#' @keywords internal
send_commit_command <- function() {
  # require("RCurl")
  send_system_command(str_c("curl ", solr_base_url(), "/solr/update --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8'"))
}

#' Send system command to Solr.
#' Send a system command to Solr to add / update files to Solr
#'
#' @author Barret Schloerke
#' @keywords internal
send_system_command <- function(system_string) {
  curled_text <- system(system_string, intern = TRUE, ignore.stderr = TRUE)
  status <- str_sub(curled_text[3], start=47, end=47)
#  if (length(status) < 1 | status == NA)
#    status <- "FAIL"

  if (!identical(status, "0")) {
    message(str_c(curled_text, collapse = "\n"))
    stop("Error uploading file to solr")
  }
  
  "success"
}