#include <cpp11.hpp>
#include <vector>
using namespace cpp11;

[[cpp11::register]]
writable::integers which_within_dist(doubles_matrix<> distmat, doubles idx, double dist) {

  int n_idx = idx.size();
  int n_matrix = distmat.ncol();
  std::vector<int> out;

  for (int i = 0; i < n_idx; i++) {
    for (int j = 0; j < n_matrix; j++) {
      if(distmat(idx[i] - 1, j) <= dist) {
        out.push_back(j + 1);
      }
    }
  }

  return out;

}
