QUERIES = {
  all_submissions: %(
    select * from submissions
  ),

  find_submissions_by_name: %(
    select * from submissions
    where name = '%s'
  )
}.freeze
