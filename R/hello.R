# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'



library("httr")

zoho_logout <- function() {
  keyring::key_delete("zoho_authtoken")
}

zoho_get_token <- function() {
  if(dim(keyring::key_list('zoho_authtoken'))[1] == 0) {
    keyring::key_set("zoho_authtoken")
  }
  invisible(keyring::key_get('zoho_authtoken'))
  # silently return so that the authtoken isn't logged in the R client
}

zoho_get_view <- function(view,criteria = list(),no_limit = false) {
  authtoken = zoho_get_token();

    url = paste("https://creator.zoho.com/api/json/klanten/view/",view,sep="");

  query = list(
    "authtoken"=authtoken,
    "scope"="creatorapi",
    "raw"="true"
  )

  # if no_limit...

  final_query = append(query,criteria)
  #print(final_query)
  r <- httr::GET(url,
           query = final_query,
           httr::timeout(seconds = 30)
  )
  httr::stop_for_status(r)

  content <- (httr::content(r, "parsed",type="application/json"))
  #print(names(content))
  data <- content[[names(content)[1]]]

  df <- data.frame(matrix(unlist(data), nrow=length(data), byrow=T),stringsAsFactors=FALSE)
  names(df) <- names(data[[1]])

  return(df)

}
