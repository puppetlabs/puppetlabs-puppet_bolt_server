plan local_plan::test(
) {
  $query_results = puppetdb_query('nodes[]{}')
  return $query_results
}
