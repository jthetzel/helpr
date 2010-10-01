#' Deletes everything that belongs to a package in solr.
#'
#' @param package package to be deleted
#' @author Barret Schloerke \email{schloerke@@gmail.com}
# '
solr_delete_package <- function(package) {
  if (! solr_exists()) return(NULL)
  
  site <- str_c("<delete><query>id:/package/",package,"/*</query></delete>")
  
  put_string(site)
}


#' Read URL
#' Retrieve the text from a url
#' 
#' @param url_string url to explore
#' @return plain text from that url
#' @author Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal
read_url <- function(url_string) {
  url_connect <- url(utils::URLencode(url_string))
  on.exit(close(url_connect))
  output <- suppressWarnings(str_c(readLines(url_connect), collapse = ""))
  output
}

#' URL made of JSON to list
#'
#' @param url_string url that contains a JSON output to be turned into a list
#' @author Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal
urlJSON_to_list <- function(url_string) {
  print(url_string)
  rjson::fromJSON(read_url(url_string))
}

#' Send commit command to Solr
#' Send a commit command to Solr to finalized any submissions
#'
#' @author Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal
send_commit_command <- function() {
  send_system_command(str_c("curl ", solr_base_url(), "/solr/update --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8'"))
}

#' Send system command to Solr
#' Send a system command to Solr to add / update files to Solr
#'
#' @author Barret Schloerke \email{schloerke@@gmail.com}
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