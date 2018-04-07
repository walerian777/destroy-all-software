require 'pg'

class Database
  def self.connect(db_url, queries)
    pg_conn = PG::Connection.new(db_url)
    new(pg_conn, queries)
  end

  def initialize(pg_conn, queries)
    @pg_conn = pg_conn
    @queries = queries
  end

  def exec_sql(sql)
    @pg_conn.exec(sql).to_a
  end

  def method_missing(name, *args) # rubocop:disable Style/MethodMissing
    sql = @queries.fetch(name) % args
    exec_sql(sql)
  rescue StandardError
    super
  end
end
