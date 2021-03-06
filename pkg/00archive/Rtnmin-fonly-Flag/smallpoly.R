## @knitr polysetup

polysetup <- function(nv, defsize=0.98){
# Function to set up animation of the "largest small polygon"
#   problem. This attempts to find the polygon in nv vertices
#   that has the largest area inside the polygon subject to
#   the constraint that no two vertices are more than 1 unit
#   distant from each other.
#   Ref. Graham, "The largest small hexagon" 
#    (J. Combinatorial Theory (A), vol. 18, pp. 165-170, 1975)

    nvmax <- 100 # Arbitrary limit -- change ??

    if (nv > nvmax) { stop("Too many vertices for polygon") }

    mcon <- (nv-2)*(nv-1)/2 # Number of distance constraints

    n <- 2*nv - 3 # Number of parameters in the problem

    # Thus we use a vector b[] of length n
    # Note that we use RADIAL coordinates to simplify the
    # optimization, but convert to cartesian to plot them
    # First point is always at the origin (0,0) cartesian
    # Second point is at (b[1],0) in both cartesian or polar
    # where cartesian is (x, y) and radial is (radius, angle)
    # Choice: angle in radians. ??
    # There are 2*nv cartesian coordinate values
    # i.e., (x, y) for nv point
    # But first point is (0,0) and second has angle 0
    #   since point 2 fixed onto x axis (angular coordinate 0).
    # So b[1] ... b[nv-1] give radial coordinates of points 2:nv
    # and b[nv] ... b[2*nv-3] give angle coordinates of points 3:nv
    # ?? not needed LET L8=nv-3: REM so l+l8 indexes angles as l=3..nv
    # Distances between points can be worked out by cosine rule for
    # triangles i.e. D = sqrt(ra^2 + rb^2 - 2 ra rb cos(angle)
    # Now set lower and upper bounds

    lb <- rep(0, n) # all angles and distances non-negative

    ub <- c(rep(1, (nv-1)), rep(pi, (nv-2))) # distances <=1, angles <= pi

    # if we have angles > pi, then we are reflecting the polygon about an edge
    # set inital parameters to a regular polygon of size .98
#    defsize <- 0.98
    regangle <- pi/nv #  pi/(no. of vertices)
# test to define polygon
    q5 <- defsize * sin(regangle) # REM regangle/nv = alpha
    b <- rep(NA,n)
#    x <- rep(NA, nv)
#    y <- rep(NA, nv)
#    x[1] <- 0
#    y[1] <- 0
#    x[2] <- q5
#    y[2] <- 0
    b[1] <- q5
    q1 <- q5
    q2 <- 0 # x2 and y2
    l8 <- nv - 3 # offset for indexing
    for (ll in 3:nv){
        b[ll+l8] <- regangle
        q1 <- q1 + q5*cos(2 * (ll-2) * regangle)
        q2 <- q2 + q5 * sin(2 * (ll-2) * regangle)
#        x[ll]<-q1
#        y[ll]<-q2
        b[ll-1] <- sqrt(q1*q1 + q2*q2) # radius
    }
    res <- list(par0 = b, lb = lb, ub = ub)
}

## @knitr polypar2XY

polypar2XY <- function(b) {
# converts radial coordinates for polygon into Cartesian coordinates
#  that are more suitable for plotting
    nv <- (length(b)+3)/2
    l8 <- nv - 3 # offset for indexing
    x <- rep(NA, nv+1)
    y <- rep(NA, nv+1)
    # One extra point to draw polygon (return to origin)
    x[1] <- 0
    y[1] <- 0
    x[2] <- b[1]
    y[2] <- 0
    cumangle <- 0 # Cumulative angle of points so far
    q5 <- b[1]
    q1 <- q5 # x2
    q2 <- 0 #  y2
    for (ll in 3:nv){
        cumangle <- cumangle + b[ll+l8]
        cradius <- b[ll-1]
        q1 <- cradius*cos(cumangle)
        q2 <- cradius*sin(cumangle)
        x[ll]<-q1
        y[ll]<-q2
    }
    x[nv+1] <- 0 # to close the polygon
    y[nv+1] <- 0    
    XY <- list(x=x, y=y)
    XY
}

## @knitr polyarea

polyarea<-function(b) {
   # compute area of a polygon defined by radial coordinates
   # This IGNORES constraints
   nv <- (length(b)+3)/2
   area <- 0 
   l8 <- nv-3
   for (l in 3:nv){ # nv - 2 triangles
      q1 <- b[[l-2]] # side 1
      q2 <- b[[l-1]] # side 2
      q3 <- b[[l+l8]] # angle
      atemp <- q1*q2*sin(q3)
      area <- area + atemp
   }
   area <- area * 0.5
   area
}

## @knitr polydistXY

polydistXY <- function(XY) {
#   compute point to point distances from XY data
   nv <- length(XY$x)-1
   ncon <- (nv - 1)*(nv)/2
   dist2 <- rep(NA, ncon) # squared distances   
   ll <- 0 # index of constraint
   for (i in 1:(nv-1)){
      for (j in ((i+1):nv)){
         xi <- XY$x[i]
         xj <- XY$x[j]
         yi <- XY$y[i]
         yj <- XY$y[j]
         dd <- (xi-xj)^2 + (yi-yj)^2
         ll <- ll + 1
         dist2[ll] <- dd
      }
   }        
   dist2
}

## @knitr polypar2distXY

polypar2distXY <- function(pars) {
# compute the pairwise distances using two calls
   nv <- (length(pars) + 3)/2
   XY <- polypar2XY(pars)
   dist2 <- polydistXY(XY)
}


## @knitr polypardist2

polypardist2 <- function(b) {
# compute the pairwise distances for non-radii lines
   nv <- (length(b) + 3)/2 
   l8 <- nv - 3 # end of radii params
   ll <- 0 # count the distances (non-radii ones)
   sqdist <- rep(NA, (nv-1)*(nv-2)/2)
   for (ii in 2:(nv-1)){
      for (jj in (ii+1):nv) {
          ra <- b[ii-1]
          rb <- b[jj-1]
          angleab <- 0
          for (kk in (ii+1):jj) { angleab <- angleab + b[kk+l8] }
          d2 <- ra*ra+rb*rb -2*ra*rb*cos(angleab) # Cosine rule for squared dist
          ll <- ll+1
          sqdist[[ll]] <- d2
      }
   }  
   sqdist
}

## @knitr polyobj

polyobj <- function(x, penfactor=1e-8, epsilon=0) {
# log barrier objective function for small polygon
# epsilon <- 0
 bignum <- 1e+20
 # (negative area) + penfactor*(sum(squared violations))
 nv = (length(x)+3)/2 # number of vertices
 area <- polyarea(x) # area
 f <- - area 
 dist2 <- polypardist2(x) # from radial coords, excluding radii (bounded)
 slacks <- 1.0 + epsilon - dist2 # slack vector
 if (any(slacks <= 0)) { 
#     cat("polygrad: Infeasible parameters at\n")
#     print(x)
     f <- bignum 
     area <- -area # to code for infeasible and avoid plotting
 } # in case of step into infeasible zone
 else {  f <- f - penfactor*sum(log(slacks)) }
 attr(f,"area") <- area
 attr(f,"minslack") <- min(slacks)
 f
}


## @knitr polyobjp

polyobjp <- function(x, penfactor=1e-8, epsilon=0) {
# log barrier objective function for small polygon
# epsilon <- 0
 bignum <- 1e+20
 # (negative area) + penfactor*(sum(squared violations))
 nv = (length(x)+3)/2 # number of vertices
 cat("x:")
 print(x)
 area <- polyarea(x) # area
 f <- - area 
 dist2 <- polypardist2(x) # from radial coords, excluding radii (bounded)
 slacks <- 1.0 + epsilon - dist2 # slack vector
 if (any(slacks <= 0)) { 
     cat("polyobjp: Infeasible parameters at\n")
     print(x)
     f <- bignum 
     area <- -area # to code for infeasible and avoid plotting
 } # in case of step into infeasible zone
 else {  f <- f - penfactor*sum(log(slacks)) }
 attr(f,"area") <- area
 attr(f,"minslack") <- min(slacks)
 f
}

## @knitr polygradp

polygradp <- function(x, penfactor=1e-8, epsilon=0) {
# log barrier gradient function for small polygon
 nv <- (length(x)+3)/2
 l8 <- nv - 3 # end of radii params
# epsilon <- 0
 bignum <- 1e+20
 # (negative area) + penfactor*(sum(squared violations))
 nn <- length(x)
 gg <- rep(0, nn)
 dist2 <- polypardist2(x) # from radial coords, excluding radii (bounded)
 slacks <- 1.0 + epsilon - dist2 # slack vector
 if (any(slacks <= 0)) { 
    cat("polygrad: Infeasible parameters at\n")
    print(x)
    warning("polygrad: Infeasible") 
    return(gg)
 } 
 for (ll in 3:nv) {
    ra<-x[ll-1]
    rb<-x[ll-2]
    abangle <- x[l8 + ll]
    # are is 0.5*ra*rb*sin(abangle)
    gg[ll-2] <- gg[ll-2] - 0.5*ra*sin(abangle)
    gg[ll-1] <- gg[ll-1] - 0.5*rb*sin(abangle)
    gg[ll+l8] <- gg[ll+l8] - 0.5*ra*rb*cos(abangle)
 }
 ll <- 0
 for (ii in 2:(nv-1)){
    for (jj in (ii+1):nv) {
       ll <- ll+1
       ra <- x[ii-1]
       rb <- x[jj-1]
       angleab <- 0
       for (kk in (ii+1):jj) { angleab <- angleab + x[kk+l8] }
       gg[ii-1] <- gg[ii-1] + 2*penfactor*(ra-rb*cos(angleab))/slacks[ll]
       gg[jj-1] <- gg[jj-1] + 2*penfactor*(rb-ra*cos(angleab))/slacks[ll]
       for (kk in (ii+1):jj){
          gg[kk+l8]<-gg[kk+l8]+2*penfactor*ra*rb*sin(angleab)/slacks[ll]
       }
    }
 }
 gg
}


## @knitr polygrad

polygrad <- function(x, penfactor=1e-8, epsilon=0) {
# log barrier gradient function for small polygon
 nv <- (length(x)+3)/2
 l8 <- nv - 3 # end of radii params
# epsilon <- 0
 bignum <- 1e+20
 # (negative area) + penfactor*(sum(squared violations))
 nn <- length(x)
 gg <- rep(0, nn)
 dist2 <- polypardist2(x) # from radial coords, excluding radii (bounded)
 slacks <- 1.0 + epsilon - dist2 # slack vector
 if (any(slacks <= 0)) { 
    cat("polygrad: Infeasible parameters at\n")
    print(x)
    stop("polygrad: Infeasible") 
 } 
 for (ll in 3:nv) {
    ra<-x[ll-1]
    rb<-x[ll-2]
    abangle <- x[l8 + ll]
    # are is 0.5*ra*rb*sin(abangle)
    gg[ll-2] <- gg[ll-2] - 0.5*ra*sin(abangle)
    gg[ll-1] <- gg[ll-1] - 0.5*rb*sin(abangle)
    gg[ll+l8] <- gg[ll+l8] - 0.5*ra*rb*cos(abangle)
 }
 ll <- 0
 for (ii in 2:(nv-1)){
    for (jj in (ii+1):nv) {
       ll <- ll+1
       ra <- x[ii-1]
       rb <- x[jj-1]
       angleab <- 0
       for (kk in (ii+1):jj) { angleab <- angleab + x[kk+l8] }
       gg[ii-1] <- gg[ii-1] + 2*penfactor*(ra-rb*cos(angleab))/slacks[ll]
       gg[jj-1] <- gg[jj-1] + 2*penfactor*(rb-ra*cos(angleab))/slacks[ll]
       for (kk in (ii+1):jj){
          gg[kk+l8]<-gg[kk+l8]+2*penfactor*ra*rb*sin(angleab)/slacks[ll]
       }
    }
 }
 gg
}


## @knitr polyobju

polyobju <- function(x, penfactor=1e-8, epsilon=0) {
# polyobj with radial parameters constrained by log barrier
# epsilon <- 0
 bignum <- 1e+20
 # (negative area) + penfactor*(sum(squared violations))
 nv = (length(x)+3)/2 # number of vertices
 area <-  polyarea(x) 
 f <- -area # negative area
 dist2 <- polypardist2(x) # from radial coords, excluding radii (bounded)
 dist2 <- c(x[1:(nv-1)]^2, dist2) # Add in radials. Note the squared distances used
 slacks <- 1.0 + epsilon - dist2 # slack vector
 if (any(slacks <= 0)) { 
    f <- bignum 
    attr(f,"area") <- -area
 } # in case of step into infeasible zone
 else {  
    f <- f - penfactor*sum(log(slacks)) 
    attr(f,"area") <- area
 }
 attr(f,"minslack") <- min(slacks)
#  pt1$add(x, -attr(f,"minslack"), attr(f, area), f)
 f
}

## @knitr polygradu

polygradu <- function(x, penfactor=1e-8, epsilon=0) {
 nv <- (length(x)+3)/2
 l8 <- nv - 3 # end of radii params
# epsilon <- 0
 # (negative area) + penfactor*(sum(squared violations))
 nn <- length(x)
 gg <- rep(0, nn)
 dist2 <- polypardist2(x) # from radial coords, excluding radii (bounded)
 dist2 <- c(x[1:(nv-1)]^2, dist2)
 slacks <- 1.0 + epsilon - dist2 # slack vector

 if (any(slacks <= 0)) { # Leave gradient at 0, rely on bignum in polyobju
    cat("polygrad: Infeasible parameters at\n")
    print(x)
     oldw <- getOption("warn")
     options(warn = -1)
     warning("Polygradu -- Infeasible")  
     options(warn = oldw)
 } else { 
   for (ll in 3:nv) {
     ra<-x[ll-1]
     rb<-x[ll-2]
     abangle <- x[l8 + ll]
     # are is 0.5*ra*rb*sin(abangle)
     gg[ll-2] <- gg[ll-2] - 0.5*ra*sin(abangle)
     gg[ll-1] <- gg[ll-1] - 0.5*rb*sin(abangle)
     gg[ll+l8] <- gg[ll+l8] - 0.5*ra*rb*cos(abangle)
   }
 }
 ll <- 0
 # components from radial parameter constraints (upper bounds)
 for (ii in 1:(nv-1)){
    ll <- ll+1
    gg[ll] <- gg[ll] + 2*penfactor*x[ll]/slacks[ll]
 }
 # components from other distances
 for (ii in 2:(nv-1)){
    for (jj in (ii+1):nv) {
       ll <- ll+1
       ra <- x[ii-1]
       rb <- x[jj-1]
       angleab <- 0
       for (kk in (ii+1):jj) { angleab <- angleab + x[kk+l8] }
       gg[ii-1] <- gg[ii-1] + 2*penfactor*(ra-rb*cos(angleab))/slacks[ll]
       gg[jj-1] <- gg[jj-1] + 2*penfactor*(rb-ra*cos(angleab))/slacks[ll]
       for (kk in (ii+1):jj){
          gg[kk+l8]<-gg[kk+l8]+2*penfactor*ra*rb*sin(angleab)/slacks[ll]
       }
    }
 }
 gg
}


## @knitr polyobjq

polyobjq <- function(x, penfactor=0, epsilon=0) {
 # negative area + penfactor*(sum(squared violations))
 nv = (length(x)+3)/2 # number of vertices
 area  <-  polyarea(x) # negative area
 f <- -area
 XY <- polypar2XY(x)
 dist2 <- polydistXY(XY)
 viol <- dist2[which(dist2 > 1)] - 1.0
 f <- f + penfactor * sum(viol)
 slacks <- 1.0 + epsilon - dist2 # slack vector
 if (any(slacks <= 0)) { 
    attr(f,"area") <- -area
 } # in case of step into infeasible zone
 else {  
    attr(f,"area") <- area
 }
 attr(f,"minslack") <- min(slacks)
 f
}

## @knitr polyobjbig

polyobjbig <- function(x, bignum=1e10, epsilon=0) {
 # Put objective to bignum when constraints violated
 nv = (length(x)+3)/2 # number of vertices
 area <- polyarea(x)
 d2 <- c(x[1:(nv-1)]^2, polypardist2(x)) # distances
 slacks <- 1.0 + epsilon - d2 # slack vector
 if (any(d2 >=1) ) { 
     f <- bignum 
     attr(f,"area") <- -area
 } else { 
    f <-  -area 
    attr(f,"area") <- area
 } # negative area
 attr(f,"minslack") <- min(slacks)
 f
}


## @knitr PolyTrack

library(R6)
library(TeachingDemos)

 nvex <- 6 # default value -- need to check if we can change 

PolyTrack <- R6Class("PolyTrack",
  public = list(
    parms = list(),
    maxviol = list(),
    areas = list(),
    fvals =list(),
    nv = nvex,
    PlotIt = TRUE,
    Delay = 0.25,
    nPolys = 5,
    add = function(p,v,a, fval) { # add points of polygon and area
      i <- length(self$parms) + 1
      self$parms[[i]] <- p # the points
      self$maxviol[[i]] <- v # maximum violation
      self$areas[[i]] <- a # the area
      self$fvals[[i]] <- fval # objective
      if(self$PlotIt) { # here PlotIt in environment is TRUE so we'll likely always do this
        self$PlotPolys() # plot all polygons to date, then wait
        Sys.sleep(self$Delay)
      }
      return(a)
    },
    PlotPolys = function(i=-1) { # to draw the polygons
      if(i<0) i <- length(self$parms)
      if(i==0) return()
      cols <- hsv(0.6, (1:self$nPolys)/self$nPolys, 1)
      # sets up a vector of colours. In this case we want gradual fade-out
      # of the older polygons so we can see the latest the best
      start <- pmax(1, i-self$nPolys+1)
      plotParms <- self$parms[seq(start,i)]
      n <- length(plotParms)
      if(n < self$nPolys) cols <- tail(cols, n)
      coords <- lapply(plotParms, function(x) polypar2XY(self$nv, x))
      plot.new()
      plot.window( xlim=do.call(range, lapply(coords, function(xy) xy$x)),
                   ylim=do.call(range, lapply(coords, function(xy) xy$y)),
                   asp=1)
      for(ii in seq_len(n)) { # draw the edges of polygons in the set
        polygon(coords[[ii]]$x, coords[[ii]]$y, border=cols[ii], lwd=3)
      }
      # Here add display of area found
      carea <- max(unlist(self$areas))
#      txt <- paste("Max polygon area =",carea,"  last=",unlist(self$areas)[-1])
      txt <- paste("Max polygon area =",carea)
      title(main=txt)
      title(sub=paste("Max violation=",self$maxviol[[i]],"  obj.fn.=",self$fvals[[i]]))
    }
  ) # end of public list, no private list
# NOTE: Need to change nv to whatever is current value
                     
)

## @knitr polyex0

# Example code
nv <- 6
cat("Polygon data:\n")
myhex <- polysetup(nv)
print(myhex)
x0 <- myhex$par0 # initial parameters
cat("Area:\n")
myhexa <- polyarea(x0)
print(myhexa)
cat("XY coordinates\n")
myheXY <- polypar2XY(x0)
print(myheXY)
plot(myheXY$x, myheXY$y, type="l")
cat("Constraints:\n")
myhexc<-polydistXY(myheXY)
print(myhexc)
cat("Vertex distances:")
print(sqrt(myhexc))
cat("check distances with polypar2distXY\n")
try1 <- polypar2distXY(x0)
print(try1)
cat("check distances with polypardist2 augmenting output with parameter squares\n")
try2 <- polypardist2(x0)
try2 <- c(x0[1:(nv-1)]^2, try2)
print(try2)
cat("Max abs difference = ",max(abs(try1-try2)),"\n")



tmp <- readline("continue to rest of examples")


## @knitr polyexq

start <- myhex$par0 # starting parameters (slightly reduced regular hexagon)
lb <- myhex$lb
ub <- myhex$ub
cat("Starting parameters:")
print(start)

library(minqa)
cat("Attempt with quadratic penalty\n")
sol1 <- bobyqa(start, polyobjq, lower=lb, upper=ub, control=list(iprint=2), penfactor=100)
print(sol1)
cat("area = ",polyarea(sol1$par),"\n")

## @knitr polyexbig

library(optimrx)
cat("Attempt with setting objective big on violation\n")

x0 <- myhex$par0 # starting parameters (slightly reduced regular hexagon)
cat("Starting parameters:")
print(x0)
meths <- c("Nelder-Mead", "nmkb", "hjkb", "newuoa")
solb <- opm(x0, polyobjbig, method=meths, bignum=1e+10)
print(solb)

## @knitr polyexbigplot

NMpar <- unlist(solb["Nelder-Mead",1:9])
nmkbpar <- unlist(solb["nmkb",1:9])
print(NMpar)
cat("Nelder-Mead area=", polyarea(NMpar))
print(nmkbpar)
cat("nmkb area=", polyarea(nmkbpar))
NMXY <- polypar2XY(NMpar)
nmkbXY <- polypar2XY(nmkbpar)
plot(NMXY$x, NMXY$y, col="red", type="l", xlim=c(-.25,0.85), ylim=c(-.05, 1.05), xlab="x", ylab="y")
points(nmkbXY$x, nmkbXY$y, col="blue", type="l")
title(main="Hexagons from NM (red) and nmkb (blue)")


## @knitr polyex2

library(minqa)
cat("Attempt with logarithmic barrier\n")

x0 <- myhex$par0 # starting parameters (slightly reduced regular hexagon)
lb <- myhex$lb
ub <- myhex$ub
cat("Starting parameters:")
print(x0)
sol2 <- bobyqa(x0, polyobj, lower=lb, upper=ub, control=list(iprint=2), penfactor=1e-3)
print(sol2)
cat("Area found=",polyarea(sol2$par),"\n")

## @knitr polyex2a

## library(optimrx)
## cat("Attempt with logarithmic barrier using nmkb and hjkb\n")

## sol2a <- opm(x0, polyobjbig, method=meths, bignum=1e+10)
## print(sol2a)


## @knitr polyex3g

library(Rvmmin)
cat("try to reduce the penalty factor. Rvmmin minimizer on polyobj\n")
restart <- x0
bestarea <- 0
lb <- myhex$lb
ub <- myhex$ub
area <- polyarea(x0)
pf <- 0.01
while (bestarea + 1e-14 < area) {
  bestarea <- area
  sol3v <- Rvmmin(restart, polyobj, polygrad, lower=lb, upper=ub, control=list(trace=2, maxit=1000), penfactor=pf)
  sol3v
  restart <- sol3v$par
  area <- polyarea(restart)
  cat("penfactor = ", pf,"   area = ",area," change=",area-bestarea,"\n")
  pf <- pf*0.1
#  tmp <- readline("Next cycle")
}
cat("Parameters from polyex3g\n")
sol3vpar <- sol3v$par
f <- polyobj(sol3vpar, penfactor=pf)
cat("Objective =", f," area =",attr(f,"area"),"  minslack=",attr(f,"minslack"),"\n")


## @knitr polyex4

x0 <- myhex$par0
bmeth <- c("nmkb", "hjkb", "bobyqa")
library(optimrx)
smult <- opm(x0, polyobj, lower=lb, upper=ub, method=bmeth, control=list(trace=1, maxit=10000), penfactor=1e-3)
print(smult )


## @knitr polyex5

## x0 <- myhex$par0
## library(nloptr)
## cat("Still have to put in nloptr calls\n")


## @knitr polyexuall

library(optimrx)
suall <- opm(x0, polyobju, polygradu, control=list(trace=1, all.methods=TRUE, kkt=FALSE), penfactor=1e-5)
# NOTE: Got complex Hessian eigenvalues when trying for KKT tests
suall <- summary(suall, order=value)
print(suall)
resu <- coef(suall)
nmeth <- dim(resu)[1]

## @knitr allplotu

mheXY <- polypar2XY(x0)
plot(mheXY$x, mheXY$y, col='red', type='l', xlim=c(-0.5, 1.05), ylim=c(-0.1, 1.2), xlab='x', ylab='y')
for (ii in 1:nmeth){
   mpar <- resu[ii,]
   XY <- polypar2XY(mpar)
   points(XY$x, XY$y, type='l', col='green')
}
   
## @knitr polyexallb

# library(optimrx)
bmeth <- c("bobyqa", "L-BFGS-B", "lbfgsb3", "Rvmmin", "Rtnmin", "Rcgmin", "nlminb", "nmkb", "hjkb", "hjn")
suball <- opm(x0, polyobj, polygrad, lower=lb, upper=ub, method=bmeth, 
        control=list(trace=1, kkt=FALSE), penfactor=1e-5)
# NOTE: Got complex Hessian eigenvalues when trying for KKT tests
suball <- summary(suball, order=value)
print(suball)
resb <- coef(suball)
nmeth <- dim(resb)[1]

## @knitr polyexhjn

library(optimrx)
# repeat of earlier code to ensure we have start and bounds
start <- myhex$par0 # starting parameters (slightly reduced regular hexagon)
lb <- myhex$lb
ub <- myhex$ub
cat("Starting parameters:")
print(start)
x0 <- start

shjnp <- opm(x0, polyobj, polygrad, lower=lb, upper=ub, method="hjn", 
        control=list(trace=1, kkt=FALSE), penfactor=1e-5)
tmp <- readline("continue")

shjnp1 <- optimr(x0, polyobj, polygrad, lower=lb, upper=ub, method="hjn", hessian=FALSE,
        control=list(trace=1, kkt=FALSE), penfactor=1e-5)
tmp <- readline("continue")

shjn0p <- hjn(x0, polyobj, lower=lb, upper=ub, bdmsk=NULL, control=list(trace=1), penfactor=1e-5)


## @knitr polyexlbfgs

  newfn <- function(spar, fonly=FALSE,  ...){
     f <- efn(spar, ...)
     if (! fonly) { 
        g <- egr(spar, ...)
        attr(f,"gradient") <- g
     } else { attr(f, "gradient") <- NULL }
     attr(f,"hessian") <- NULL # ?? maybe change later
     f
  }

library(Rtnmin)
stnb <- tnbc(x0, newfn, lower=lb, upper=ub, trace=TRUE)
stnb



# library(optimrx)


bmeth <- c("L-BFGS-B", "lbfgsb3", "Rtnmin")
suball <- opm(x0, polyobjp, polygrad, lower=lb, upper=ub, method=bmeth, 
        control=list(trace=1, kkt=FALSE), penfactor=1e-5)
# NOTE: Got complex Hessian eigenvalues when trying for KKT tests
suball <- summary(suball, order=value)
print(suball)
resb <- coef(suball)
nmeth <- dim(resb)[1]

