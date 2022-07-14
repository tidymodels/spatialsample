#include <cpp11.hpp>
#include <vector>
using namespace cpp11;

[[cpp11::register]]
cpp11::writable::integers which_within_dist(doubles_matrix<> distmat, doubles idx, double dist) {

  int n_idx = idx.size();
  int n_matrix = distmat.ncol();
  std::vector<bool> comparisons(n_matrix);
  int cur_row;

  for (int i = 0; i < n_idx; i++) {
    cur_row = idx[i] - 1;
    for (int j = 0; j < n_matrix; j++) {
      if (distmat(cur_row, j) <= dist) {
        comparisons[j] = true;
      }
    }
  }

  auto n_pos = std::count(comparisons.begin(), comparisons.end(), true);
  std::vector<int> out(n_pos);
  int cur_idx = 0;
  for (int i = 0; i < n_matrix; i++) {
    if (comparisons[i]) {
      out[cur_idx] = i + 1;
      ++cur_idx;
    }
  }

  return out;

}
