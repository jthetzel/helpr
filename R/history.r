#' Session History
#' 
#' @return fuctions that are from a package
get_function_history <- function(){
  rawhist <- NULL
  a <- NULL
  pattern <- "[a-zA-Z_.][a-zA-Z_.0-9]*\\("
  file1 <- tempfile("Rrawhist")
  savehistory(file1)
  rawhist <- readLines(file1)
  unlink(file1)

  # subset then find function names
  rawhist <- grep(pattern, rawhist, value = TRUE )
  funcs <- unlist(str_extract_all(rawhist, pattern))
  funcs <- funcs[ ! funcs %in% c("if(", "for(", "while(", "get_function_history(")]
  funcs <- str_replace(funcs, "[(]", "")

  funcs
}


#' Last Ten Functions
#' 
#' @param fun_list function list
#' @return fuctions that are from a package and their help paths
last_ten_functions <- function(fun_list = get_function_history()){  
  unique_fun_list <- unique(rev(fun_list))
  
  last_ten_funcs <- subset(
    data.frame(
      func = unique_fun_list, 
      path = function_help_path(unique_fun_list), 
      stringsAsFactors = FALSE
    ), 
    !is.na(path)
  )
  last_ten <- min(10, NROW(last_ten_funcs))
  last_ten_funcs[seq_len(last_ten), ]

}

#' Top Ten Functions
#' 
#' @param fun_list function list
#' @return fuctions that are from a package and their help paths
top_ten_functions <- function(fun_list = get_function_history()){  
  func_count <- table(fun_list)
  
  func_count <- func_count[order(func_count, decreasing = TRUE)]
  
  func_name <- names(func_count)

  top_ten_funcs <- subset(
    data.frame(
      func = func_name, 
      path = function_help_path(func_name), 
      stringsAsFactors = FALSE
    ), 
    !is.na(path)
  )

  top_ten <- min(10, NROW(top_ten_funcs))
  top_ten_funcs[seq_len(top_ten), ]
}


#' Top Ten and Last Ten Functions
#' 
#' @return list containing the \code{\link{top_ten_functions}} and \code{\link{last_ten_functions}}
ten_functions <- function(){
  fun_hist <- get_function_history()

  list(
    last_ten = last_ten_functions(fun_hist),
    top_ten = top_ten_functions(fun_hist)
  )
}


