#' Request measured volumes in strategic reservoirs from FUNCEME API. id, requestDate and returnN (number of points that should be returned)
#' @import jsonlite
#' @export
requestVolumes <- function(id,requestDate,returnN) {
  if(missing(requestDate)) {
    requestDate=strftime(Sys.time()-3*60*60*24,format="%Y-%m-%d")
  }
  if(missing(returnN)) {
    returnN=1
  }
  if(missing(id)) {
    id=9
  }

  if(grepl('POSIX',class(requestDate)[1])) {
    requestDateAPI = format(requestDate,tz="America/Fortaleza",format="%Y-%m-%d")
  } else {
    requestDateAPI = requestDate
  }

  request=paste0('http://api.funceme.br/rest/acude/volume?reservatorio.cod=',
    id,
    '&limit=',
    returnN,
    '&dataColeta.GTE=',
    requestDateAPI,
    '&orderBy=dataColeta,cres')

  vols=fromJSON(request)

  value=vols$list$valor

  if(is.null(value)) {
    warning(paste0("No values for id ",id," recorded after requested date ",requestDate))
    value=NA
  }
  dt=strptime(vols$list$dataColeta,format="%Y-%m-%d %H:%M:%S",tz="America/Fortaleza")
  if(length(dt)==0) {
    dt=NA
  }
  volOut=data.frame(returnedDate=dt,requestDate=requestDate,value=value,cod=id)

  # if observation date is more than two weeks apart from our requested date, only NA is returned
  largediff=as.numeric(difftime(volOut$returnedDate,volOut$requestDate,units='days'))>14
  volOut$value[largediff]=NA
  volOut$returnedDate[largediff]=NA
  return(volOut)
}


#
# #' convert volumes from API into areas based on CAV obtained on the API and stored in this package
# #' @import jsonlite,dplyr
# #' @export
# vol2area <- function(voldf,CAV) {
#   filter(CAV,codigo==)
# }
#
#
# #' convert volumes from API into areas based on CAV obtained on the API and stored in this package
# #' @import jsonlite,dplyr
# #' @export
# vol2area <- function(voldf,CAV) {
#   filter(CAV,codigo==)
# }
