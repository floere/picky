# Wrapper for the mysql adapter method execute
# to handle the 8 hours disconnect problem.
# (http://www.mysql.fr/search/?q=autoreconnect)
#
ActiveRecord::ConnectionAdapters::MysqlAdapter.module_eval do
  def execute_with_retry_once(sql, name = nil)
    retried = false
    begin
      execute_without_retry_once(sql, name)
    rescue ActiveRecord::StatementInvalid => statement_invalid_exception
      # Our database connection has gone away, reconnect and retry this method
      #
      reconnect!
      unless retried
        retried = true
        retry
      end
    end
  end

  alias_method_chain :execute, :retry_once
end
