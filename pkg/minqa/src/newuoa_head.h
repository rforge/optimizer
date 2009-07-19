typedef struct opt_struct {
  SEXP par;
  SEXP fcall;
  SEXP env;
  double rss;
  int feval;
} opt_struct, *OptStruct;

SEXP getListElement(SEXP list, char *str);
double *real_vector(int n);
int  *int_vector(int n);

SEXP newuoa_c(SEXP par_arg, SEXP fn, SEXP control, SEXP rho);
double resfun(int n, double *par, double *f);

void F77_NAME(newuoa)(int *N,
		      int *NPT, double *X, double
		      *RHOBEG, double *RHOEND, int *IPRINT, 
		      int *MAXFUN, double *W);
		     
void F77_SUB(resfun)(int *n, double *par, double *f); 
					   
extern OptStruct OS;

