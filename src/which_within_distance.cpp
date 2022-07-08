#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector which_within_dist(NumericMatrix distmat, NumericVector idx, double dist) {

  int n_idx = idx.size();
  int n_matrix = distmat.ncol();

  int n_pos = 0;
  for (int i = 0; i < n_idx; i++) {
    n_pos += sum(distmat(idx[i] - 1, _) <= dist);
  }

  int p = 0;
  IntegerVector out(n_pos);
  for (int i = 0; i < n_idx; i++) {
    for (int j = 0; j < n_matrix; j++) {
      if (distmat(idx[i] - 1, j) <= dist) {
        out(p) = (j + 1);
        p++;
      }
    }
  }

  return out;

}
