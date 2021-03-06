# Optimization test function lanczos1
# lanczos1 from NISTnls
# ??ref...


lanczos1.f <- function(x) {
   res<-lanczos1.res(x)
   f<-sum(res*res)
}

lanczos1.res <- function(b) {
   xx<-Lanczos1$x # note case!
   yy<-Lanczos1$y
   res <- rep(NA, length(xx))
   b1<-b[1]
   b2<-b[2]
   b3<-b[3]
   b4<-b[4]
   b5<-b[5]
   b6<-b[6]
   res<-b1*exp(-b2*xx) + b3*exp(-b4*xx) + b5*exp(-b6*xx) - yy
   return(res)
}

# lanczos1 - Jacobian
lanczos1.jac <- function(b) {
stop("not defined")
   xx<-Lanczos1$x
   yy<-Lanczos1$y
   n<-length(b)
   m<-length(xx)
   b1<-b[1]
   b2<-b[2]
   b3<-b[3]
   J<-matrix(0,m,n) # define the size of the Jacobian
    return(J)
}

lanczos1.h <- function(x) {
stop("not defined")
   JJ<-lanczos1.jac(x)
   H <- t(JJ) %*% JJ
   res<-lanczos1.res(x)
stop("not defined")

}

lanczos1.g<-function(x) {
#   stop("not defined")
   JJ<-lanczos1.jac(x)
   res<-lanczos1.res(x)
   gg<-as.vector(2.0*t(JJ) %*% res)
   return(gg)
}

lanczos1.fgh<-function(x) {
   f<-lanczos1.f(x)
   g<-lanczos1.g(x)
   H<-lanczos1.h(x)
   fgh<-list(value=f,gradient=g,hessian=H)
}

lanczos1.setup<-function() {
   library(NISTnls) # get parent collection
   data(Lanczos1) # and load up the data into x and y
}

lanczos1.test<-function() {
  start1<-c(1.2,0.3,5.6,5.5,6.5,7.6)
  start2<-c(0.5,0.7,3.6,4.2,4,6.3)

}   
