List<double> getDummyChartData(String from, String to) {
  if (from == "USD" && to == "PKR") {
    return [276, 277, 278, 276.5, 277.2, 278.1, 277.9];
  } else if (from == "EUR" && to == "PKR") {
    return [297, 298, 299, 298.5, 299.2, 300.1, 299.8];
  } else if (from == "GBP" && to == "PKR") {
    return [350, 351, 349, 352, 351.5, 353, 352.2];
  } else {
    return [1, 1.1, 1.05, 1.2, 1.15, 1.18, 1.22];
  }
}
